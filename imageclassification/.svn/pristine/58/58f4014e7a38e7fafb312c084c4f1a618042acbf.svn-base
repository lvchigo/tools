function plot_prefermance

close all

load test_label.mat 
load predicted_label.mat 
load prob_estimates.mat

class_index = unique(test_label);
nclass = length(class_index);
fp_all = [];
tp_all = [];
auc_all = [];
for c = 1:nclass
    [tp , fp , threshold] = basicroc(test_label', prob_estimates(:,c));
    
    auc = area_under_roc(tp, fp);
    fp_all = [fp_all; fp];
    tp_all = [tp_all; tp];
    auc_all = [auc_all; auc];
    %plot(fp , tp  , 'linewidth' , 2);
    %pause;
    %close all;
end

tpmean   = reshape(mean(mean(tp_all , 1) , 3) , [1, 100]);
fpmean   = reshape(mean(mean(fp_all , 1) , 3) , [1, 100]);

tp_mean = mean(tp_all, 2);
fp_mean = mean(fp_all, 2);
auc_mean = mean(auc_all)
plot(fpmean , tpmean  , 'linewidth' , 2);

function auc = area_under_roc(tp, fp)

n = length(tp);
auc = sum((fp(2:n) - fp(1:n-1)).*(tp(2:n)+tp(1:n-1)))/2;