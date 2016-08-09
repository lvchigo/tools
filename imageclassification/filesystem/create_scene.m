function create_scene(im_orig,short_name,dir_path)

 
width = size(im_orig,1);
height = size(im_orig,2);
%{
im_resize_s = imresize(im_orig,0.618)
imwrite(im_resize_s,[dir_path,'/',short_name,'_resize_s.jpg']);
im_resize_b = imresize(im_orig,2-0.618);
imwrite(im_resize_b,[dir_path,'/',short_name,'_resize_b.jpg']);
%}
im_gray = rgb2gray(im_orig);
im_adj = imadjust(im_gray);
im_heq = histeq(im_gray);
im_gray = cat(3,im_gray,im_gray,im_gray);
im_adj = cat(3,im_adj,im_adj,im_adj);
im_heq = cat(3,im_heq,im_heq,im_heq);
imwrite(im_gray,[dir_path,'/',short_name,'_gray.jpg']);
imwrite(im_adj,[dir_path,'/',short_name,'_adj.jpg']);
imwrite(im_heq,[dir_path,'/',short_name,'_heq.jpg']);

im_light_lower = im_orig - 32;
imwrite(im_light_lower,[dir_path,'/',short_name,'_light_lower.jpg']);
im_light_upper = im_orig + 32;
imwrite(im_light_upper,[dir_path,'/',short_name,'_light_upper.jpg']);

im_r = cat(3,im_orig(:,:,1),zeros(width,height),zeros(width,height));
imwrite(im_r,[dir_path,'/',short_name,'_r.jpg']);
im_g = cat(3,zeros(width,height),im_orig(:,:,2),zeros(width,height));
imwrite(im_g,[dir_path,'/',short_name,'_g.jpg']);
im_b = cat(3,zeros(width,height),zeros(width,height),im_orig(:,:,3));
imwrite(im_b,[dir_path,'/',short_name,'_b.jpg']);

im_rot_20 = imrotate(im_orig,20,'bilinear','crop');
imwrite(im_rot_20,[dir_path,'/',short_name,'_rot_20.jpg']);
im_rot_40 = imrotate(im_orig,40,'bilinear','crop');
imwrite(im_rot_40,[dir_path,'/',short_name,'_rot_40.jpg']);
im_rot_60 = imrotate(im_orig,60,'bilinear','crop');
imwrite(im_rot_60,[dir_path,'/',short_name,'_rot_60.jpg']);

im_noise_g = imnoise(im_orig,'gaussian');
imwrite(im_noise_g,[dir_path,'/',short_name,'_noise_g.jpg']);
im_noise_s = imnoise(im_orig, 'salt & pepper');
imwrite(im_noise_s,[dir_path,'/',short_name,'_noise_s.jpg']);
im_noise_p = imnoise(im_orig,'poisson' );
imwrite(im_noise_p,[dir_path,'/',short_name,'_noise_p.jpg']);

im_cut_w = im_orig(1:ceil(width*0.618),:,:);
imwrite(im_cut_w,[dir_path,'/',short_name,'_cut_w.jpg']);
im_cut_h = im_orig(:,1:ceil(height*0.618),:);
imwrite(im_cut_h,[dir_path,'/',short_name,'_cut_h.jpg']);
im_cut_d = im_orig(1:ceil(width*0.618),1:ceil(height*0.618),:);
imwrite(im_cut_d,[dir_path,'/',short_name,'_cut_d.jpg']);

