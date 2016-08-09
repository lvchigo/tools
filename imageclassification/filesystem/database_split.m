function [database_train, database_test] = database_split(database, percent)
%=========================================================================
% descriptor:
% split database to trainning set and test set by random
% inputs:
% database      -a tructure of the dir
%                   .imnum  total image number of the database
%                   .nclass  total image category of the database
%                   .cname  name of each class
%                   .path   pathes for each image file
%                   .label  label for each image file
% percent    -the percent of trainning set (0.0 1.0)
% 
% outputs:
% database_train      -a tructure same as database
% database_test       -a tructure same as database
%=========================================================================

%
database_train = [];
database_train.imnum = 0; % total image number of the database
database_train.cname = database.cname; % name of each class
database_train.label = {}; % label of each class
database_train.path = {}; % contain the pathes for each image of each class
database_train.nclass = database.nclass; % total image category of the database

database_test = [];
database_test.imnum = 0; % total image number of the database
database_test.cname = database.cname; % name of each class
database_test.label = {}; % label of each class
database_test.path = {}; % contain the pathes for each image of each class
database_test.nclass = database.nclass; % total image category of the database

nclass = database.nclass;
for i = 1:nclass
    path_cell = database.path{i};
    label_cell = database.label{i};
    im_count = length(path_cell);
    split_n = ceil(im_count*percent);
    index_rnd = randperm(im_count);
    %
    database_train.imnum = database_train.imnum + split_n;
    database_train.path{i} = path_cell(index_rnd(1:split_n));
    database_train.label{i} = label_cell(index_rnd(1:split_n));
    %
    database_test.imnum = database_test.imnum + im_count - split_n;
    database_test.path{i} = path_cell(index_rnd(1+split_n:im_count));
    database_test.label{i} = label_cell(index_rnd(1+split_n:im_count));
end