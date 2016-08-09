function plot_confusion_matrix(confusion_matrix, class_names, accuracy)
%
%
%
%{
if size(confusion_matrix, 1) ~= length(class_names)
  error('confusion_matrix dimension does not match length of class_names')
end
%}

plot_accuracy = true;
if nargin ~= 3
    plot_accuracy = false;
end

nclass = size(confusion_matrix, 1);
cnames = class_names;


h = imagesc(1:nclass, 1:nclass, 1 - confusion_matrix); 
colormap(flipud(gray)); 

textStrings = num2str(confusion_matrix(:),'%0.2f');  
textStrings = strtrim(cellstr(textStrings)); 

[x,y] = meshgrid(1:nclass);
hStrings = text(x(:), y(:), textStrings(:), 'HorizontalAlignment','center');
%midValue = mean(get(gca,'CLim')); 
%textColors =  repmat(confusion_matrix(:) > midValue,1,3); 
textColors = repmat(zeros(nclass*nclass, 1), 1, 3);
set(hStrings,{'Color'},num2cell(textColors,2));   


set(gca,'yTick',1:nclass , 'xTick' , 1:nclass);

if(~isempty(cnames) && iscell(cnames))
    set(gca,'XTickLabel',cnames);
    aa=get(gca,'XTickLabel');
    bb=get(gca,'XTick');
    cc=get(gca,'YTick');
    th=text(bb,repmat(cc(end)+.6*(cc(2)-cc(1)),length(bb),1),aa,'HorizontalAlignment','left','rotation',310);
    set(th , 'fontsize' , 7)
    set(gca,'XTickLabel',{});
    set(gca,'yTickLabel',cnames);
    set(gca , 'fontsize' , 7)
end
if plot_accuracy
    set(gca,'title',text('string', sprintf('Accuracy: %f%%', accuracy))) 
end
%================================================
%{
imagesc(1:nclass, 1:nclass, 1 - confusion_matrix); 
colormap(flipud(gray)); 

textStrings = num2str(confusion_matrix(:),'%0.2f');  
textStrings = strtrim(cellstr(textStrings)); 

[x,y] = meshgrid(1:nclass);
hStrings = text(x(:), y(:), textStrings(:), 'HorizontalAlignment','center');
%midValue = mean(get(gca,'CLim')); 
%textColors =  repmat(confusion_matrix(:) > midValue,1,3); 
textColors = repmat(zeros(nclass*nclass, 1), 1, 3);
set(hStrings,{'Color'},num2cell(textColors,2));  % Change the text colors

set(gca, 'XTick', 1:nclass, 'YTick', 1:nclass); % to handle a bug

if(~isempty(cnames) && iscell(cnames))
    set(gca,'yticklabel',cnames);
    set(gca,'xticklabel',cnames,'XAxisLocation','top');
end

if plot_accuracy
    set(gca,'title', 'title');
end
%% rotate x label
rotateXLabels(gca, 90 );
%}