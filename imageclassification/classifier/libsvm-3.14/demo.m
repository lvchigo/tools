function demo()

[heart_scale_label, heart_scale_inst] = libsvmread('../heart_scale');

 % Split Data
train_data = heart_scale_inst(1:150,:);
train_label = heart_scale_label(1:150,:);
test_data = heart_scale_inst(151:270,:);
test_label = heart_scale_label(151:270,:);

% Linear Kernel
tic
model_linear = libsvmtrain(train_label, train_data, '-t 0')
toc

tic
[predict_label_L, accuracy_L, dec_values_L] = svmpredict(test_label, test_data, model_linear);
toc

% Precomputed Kernel
tic
model_precomputed = libsvmtrain(train_label, [(1:150)', train_data*train_data'], '-t 4')
toc

tic
[predict_label_P, accuracy_P, dec_values_P] = svmpredict(test_label, [(1:120)', test_data*train_data'], model_precomputed);
toc
