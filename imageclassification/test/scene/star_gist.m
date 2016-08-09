
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
%%/home/zougp/Data/
spatialenvelope_db_dir = '/home/zougp/Data/faces/star';
spatialenvelope_db_mat = '/home/zougp/Data/feature/star_db.mat';
spatialenvelope_gist_mat = '/home/zougp/Data/feature/star_gist.mat';

do_scanning = false;
do_extracting = false;
%% scan image files in the dir
if do_scanning
    se_db = database_dir_scanner(spatialenvelope_db_dir, '*.jpg');
    save(spatialenvelope_db_mat, 'se_db');
else
    load(spatialenvelope_db_mat, 'se_db');
end
%% extraxct gist descriptor
if do_extracting
    se_gist.cols = se_db.imnum;
    se_gist.nclass = se_db.nclass;
    se_gist.cname = se_db.cname;
    se_gist.label = se_db.label;

    nclass = se_gist.nclass;
    for c = 1:nclass
        gist_mat = [];
        path_cell = se_db.path{c};
        im_count = length(path_cell);
        for i = 1:im_count
            im_file = char(path_cell(i))
            img = imread(im_file);
            gist = GistDescriptor(img);
            gist_mat = [gist_mat; gist];
        end
        se_gist.gist{c} = gist_mat;
    end
    save(spatialenvelope_gist_mat, 'se_gist');
else
    load(spatialenvelope_gist_mat, 'se_gist');
end

%% split data to train set and test set
train_percent = 0.8;
train_gist = [];
train_label = [];
test_gist = [];
test_label = [];

nclass = se_gist.nclass;
for c = 1:nclass
    gist_mat = se_gist.gist{c};
    label_mat = se_gist.label{c};
    gist_count = length(label_mat);
    split_pos = ceil(train_percent*gist_count);
    index = randperm(gist_count);
    train_gist = [train_gist; gist_mat(1:split_pos, :)];
    train_label = [train_label; label_mat(1:split_pos)];
    test_gist = [test_gist; gist_mat(split_pos+1:end, :)];
    test_label = [test_label; label_mat(split_pos+1:end)];
end
%convert_to_svm_format(train_label, train_gist, 'train_mk.gist');
%convert_to_svm_format(test_label, test_gist, 'test_mk.gist');
%% svm trainning...
disp('svm trainning...');

best_c = 10;
best_g = 2;
options = sprintf('-s 0 -t 2 -c %f -b 1 -g %f -q',best_c,best_g);

model = libsvmtrain(double(train_label), double(train_gist), options);

%% svm predict...
disp('svm predict by trainning data...');
[predicted_label, accuracy, prob_estimates] = libsvmpredict(double(train_label), double(train_gist), model, '-b 1');
display(accuracy)

%% svm predict...
disp('svm predict by test data...');
[predicted_label, accuracy, prob_estimates] = libsvmpredict(double(test_label), double(test_gist), model, '-b 1');
display(accuracy)


nclass = se_gist.nclass;
cnames = se_gist.cname;

confusion_matrix = calc_confusion_matrix(test_label, predicted_label);
plot_confusion_matrix(confusion_matrix, cnames)


