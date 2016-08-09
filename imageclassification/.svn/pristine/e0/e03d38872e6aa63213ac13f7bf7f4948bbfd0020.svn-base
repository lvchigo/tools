function gist = GistDescriptor(img)
%@descript: Computing the gist descriptor
%@param: img - image data, rgb or gray 
%@return: gist - the gist descriptor, float
%         dimensions = sum(param.orientationsPerScale)*param.numberBlocks*param.fc_prefilt
%@example:
%         im = imread('demo1.jpg');
%         gist = GistDescriptor(im);

% Parameters:
clear param
param.imageSize = [256 256]; % it works also with non-square images
param.orientationsPerScale = [8 8 8 8];
param.numberBlocks = 4;
param.fc_prefilt = 4;

% Computing gist requires 1) prefilter image, 2) filter image and collect
% output energies
[gist, param] = LMgist(img, '', param);