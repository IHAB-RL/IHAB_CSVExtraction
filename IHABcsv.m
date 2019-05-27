
classdef IHABcsv < handle
    
    properties
        
        sFolderData;
        stSubject;
        
    end
    
    methods
        
        function obj = IHABcsv()
            
            addpath(genpath('functions'))
            
            obj.stSubject = struct('Name', [], 'Folder', []);
            
            obj.setDataFolder();
            
            fprintf('%s\n\n', repmat('=', 1, 33));
            fprintf('Extracting Questionnaire Data fom Folder: %s\n\n', obj.sFolderData);
            
            obj.extractAllCSV();
            
            fprintf('\n%s\n\n', repmat('=', 1, 33));
            fprintf('Concatenating all CSV Data');
            
            obj.concatenateCSV();
            
            fprintf('finished.\n')
            fprintf('\n%s\n\n', repmat('=', 1, 33));
            
        end
        
        function [] = setDataFolder(obj)
            
%             obj.sFolderData = 'E:\IHAB-rl_Auswertung\IHAB_2_EMA2018';
            obj.sFolderData = uigetdir();
            
        end
        
        function [] = extractAllCSV(obj)
            
            stDir = dir(obj.sFolderData);
            stDir(1:2) = [];
            nDirs = length(stDir);
            
            for iDir = 1:nDirs
                
                if stDir(iDir).isdir
                    
                    fprintf('Importing [%d/%d] - %s\n', iDir, nDirs, stDir(iDir).name);
                    
                    obj.stSubject.Folder = [stDir(iDir).folder, filesep, stDir(iDir).name];
                    
                    sMessage = stDir(iDir).name;
                    cMessage = regexp(sMessage, '(\w{8})_(\w)*', 'tokens');
                    
                    obj.stSubject.Name = cMessage{1}{1};
                    
                    import_EMA2018(obj);
                    
                else
                    
                    cprintf('Red', 'Excluding [%d/%d] - %s\n', iDir, nDirs, stDir(iDir).name);
                    
                end
                
            end
            
        end
        
        function [] = concatenateCSV(obj)
            
            csv_files = dir([obj.sFolderData filesep '**' filesep 'Questionnaires_*.mat']);
            
            load([csv_files(1).folder filesep csv_files(1).name], 'QuestionnairesTable')
            
            table_a = QuestionnairesTable;
            
            % concatenate all csv files into temporary 'table_a'
            for index = 2 : length(csv_files)
                
                fprintf('.');
                
                load([csv_files(index).folder filesep csv_files(index).name], 'QuestionnairesTable');
                table_b = QuestionnairesTable;
                table_a = outerjoin(table_a, table_b, 'MergeKeys', true);
                
            end
            
            % replace missing answers with code '222'
            table_a{:, 10:end}(isnan(table_a{:, 10:end})) = 222;
            
            % rearrange columns when multiple Sources were selected
            table_a = sort_columns(table_a);
            
            % copy table and write csv file
            All_Questionnaires = table_a;
            
            % sort by subjects
            All_Questionnaires = sortrows(All_Questionnaires, 'SubjectID');
            
            csv_date = datestr(datetime(), 'dd-mm-yyyy');
            save([obj.sFolderData filesep 'All_Questionnaires_' csv_date '.mat'], 'All_Questionnaires');
            writetable(All_Questionnaires, [obj.sFolderData filesep 'All_Questionnaires_' csv_date '.csv'],'Delimiter',';');
            
        end
        
    end
    
end
























