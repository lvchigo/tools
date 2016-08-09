function shituBat()

out_dir = '/home/tangyuan/ssd/Data/shitu';
im_list = '/home/tangyuan/ssd/Data/theme/theme_photo/theme_photo_327.txt';
fptr_r = fopen(im_list, 'r');

imlist = [];
while ~feof(fptr_r)

    
    rstr = fgetl(fptr_r);
    %astr = strsplit(rstr, '\t');
    astr = regexp(rstr, ',', 'split');
    t.id = char(astr{1});
    t.url = char(astr{2});
    t
    imlist{end+1} = t;
end
fclose(fptr_r);


for i = 1:length(imlist)
    
    t = imlist{i};
    
    keywords = queryShitu(t.url)
    if length(keywords) < 1
        continue;
    end
    
    for c = 1:length(keywords)
        try
        cls = keywords{c};
        sub_dir = [out_dir, '/', cls];
        mkdir(sub_dir);
        savef = fullfile(sub_dir, [t.id, '.jpg']);
        urlwrite(t.url, savef);
        display([num2str(i), '/', num2str(length(imlist)), ':', savef])
        catch
            continue;
        end
    end
    
end