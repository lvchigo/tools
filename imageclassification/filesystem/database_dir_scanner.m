function [database] = database_dir_scanner(data_dir, file_type)
%=========================================================================
% descriptor:
% scan files in the dir
% inputs:
% data_dir   -the rootpath for the database. e.g. '../data/caltech101'
% file_type  -the file type. e.g. '*.jpg'
% outputs:
% database      -a tructure of the dir
%                   .imnum  total image number of the database
%                   .nclass  total image category of the database
%                   .cname  name of each class
%                   .path   pathes for each image file
%                   .label  label for each image file
%=========================================================================

fprintf('dir the database...');
subfolders = dir(data_dir);

database = [];

database.imnum = 0; % total image number of the database
database.cname = {}; % name of each class
database.label = {}; % label of each class
database.path = {}; % contain the pathes for each image of each class
database.nclass = 0; % total image category of the database

for ii = 1:length(subfolders)
    
    if subfolders(ii).isdir == 0
        continue;
    end
    subname = strtrim(subfolders(ii).name);
   
    if ~strcmp(subname, '.') & ~strcmp(subname, '..')
        database.nclass = database.nclass + 1;
        
        database.cname{database.nclass} = subname;
        
        frames = list_file_in_dir( [data_dir, '/', subname], file_type);
        c_num = length(frames);
                    
        database.imnum = database.imnum + c_num;
        database.label{database.nclass} =  ones(c_num, 1)*database.nclass;
        path_set = frames;
        
        index_rnd = randperm(length(path_set));
        database.path{database.nclass} = path_set(index_rnd);
      
        
    end;
end;
disp('done!');

