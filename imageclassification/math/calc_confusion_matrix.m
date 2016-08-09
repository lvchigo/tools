function conf_mat = calc_confusion_matrix(truth_label, predicted_label)
%description:
%           compute the confusion matrix of a given classifier based on
%		its desired output (ground truth) and computed output.
%
%
if nargin ~= 2
    return
end

if length(truth_label) ~= length(predicted_label)
  error('truth_label dimension does not match dimension of predicted_label')
end

class_count = length(unique(truth_label));
conf_mat = zeros(class_count, class_count);
accuracy = 0;
for i = 1:class_count
	index = find(truth_label==i);
	roi = predicted_label(index);
	for j = 1:class_count
		conf_mat(i,j) = length(find(roi==j));
        if i == j
            accuracy = accuracy + conf_mat(i, j);
        end
        conf_mat(i,j) = conf_mat(i,j) / length(index);
	end
end
accuracy = accuracy / length(truth_label)