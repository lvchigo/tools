function images_save_as(input_dir, output_dir, options)


if nargin == 2
    options.name = 'new';
    options.ext = '.jpg';
end

if(~isfield(options, 'name'))
    options.name = 'new';
end
if(~isfield(options, 'ext'))
    options.ext = '.jpg';
end

if(~isfield(options, 'colorspace'))
    options.colorspace = 1;
end

file_type = '*.jpg|*.JPG|*.jpeg|*.JPEG|*.png|*.PNG';
file_list = list_file_in_dir(input_dir, file_type);

for i = 1:length(file_list)
    file_at = char(file_list{i});
    [file_p, file_n, file_e] = fileparts(file_at);
    file_out = fullfile(output_dir, [options.name, '_', num2str(i), options.ext]);
    try
        im = imread(file_at);
        % color space convert
        if options.colorspace == 0
            if size(im, 3) == 3
                im = rgb2gray(im);
            end
        end
        %resize
        if(isfield(options, 'w') && isfield(options, 'h') )
            im = imresize(im, [options.w options.h]);
        end
        imwrite(im, file_out);
    catch
        continue
    end
end