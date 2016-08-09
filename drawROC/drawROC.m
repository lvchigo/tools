function drawROC()

a=[0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0];
b=[1,0.99,0.98,0.95,0.93,0.90,0.85,0.80,0.72,0.65,0.4];
% plotROC
filename = sprintf('%s/image/roc_%s', '/home/chigo', 'logo');
fprintf('filename:%s\n',filename);
plot_roc(filename,a,b);

%% plotROC
function plot_roc(filename,recall,precision)

plot(recall,precision,'r','LineWidth',1);
% hold on;
axis([0 1 0 1]);
title('ROC');
xlabel('Recall');
ylabel('Precision');
grid on;
saveas(gcf,filename,'jpg');
