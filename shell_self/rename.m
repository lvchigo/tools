
clear all;clc;

%%  do job
filename = 'list_color.txt';
fileID = fopen(filename,'r');

i=0;
IMAGE_DIM = 256;

%% clear file && mkdir
image_save_dir = 'save';
rm_img_save_dir=sprintf('rm -rf %s/',image_save_dir);
mk_img_save_dir=sprintf('mkdir %s/',image_save_dir);
dos(rm_img_save_dir);
dos(mk_img_save_dir);

%% do
while ~feof(fileID)   
    linestr = fgetl(fileID);
    try
        im = imread(linestr);
    catch
        continue;
    end
    
    % resize to fixed input size
    try
        im = imresize(im, [IMAGE_DIM IMAGE_DIM], 'bilinear');
    catch
        continue;
    end
    
    i=i+1;
    
    if (rem(i,5) == 0)
        fprintf('Load %d img...\n',i);
    end
    
    savefile=sprintf('%s/%s_%d.jpg',image_save_dir,image_save_dir,i);   
    try
        imwrite(im,savefile);
    catch
        continue;
    end
end

fprintf('All load %d img!\n',i);
fprintf('End!!\n');

clear all;clc;
