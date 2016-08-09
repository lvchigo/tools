function gen_mcnet_pdata

addpath(genpath('/home/public/geekeyelab/imageclassification'));
warning ('off','all');

org_dir = '/home/public/data/in16c';
out_dir = '/home/public/data/in16ctrain';
mat_file = '/home/public/data/in16ctrain/imdb.mat';

ptrain = 0.98;
pval = 0.01;
ptest = 0.01;
msize = [256 256];
nmax = 12000;
%%
db_info = database_dir_scanner(org_dir, '*.jpg|*.png|*.jpeg|*.bmp|*.JPG|*.PNG|*.JPEG');
imdb.classes.name = db_info.cname ;
imdb.classes.description = db_info.cname  ;
imdb.imageDir = out_dir ;

mkdir([out_dir, '/train']);
mkdir([out_dir, '/test']);
mkdir([out_dir, '/val']);
% -------------------------------------------------------------------------
%                                                           Training images
% -------------------------------------------------------------------------

fprintf('searching training images ...\n') ;
names = {} ;
labels = {} ;

for c = 1:db_info.nclass
    
    sub_dir = [out_dir, '/train/', db_info.cname{c}];
    mkdir(sub_dir);
    ndb = min(length(db_info.path{c}), nmax);

    
    ntrain = floor(ndb*ptrain);
    idx = 1;
    for i = 1:ntrain
        
        imf = db_info.path{c}{i}
        try
            im = imread(imf);
            imr = imresize(im, msize);
            savef = fullfile(sub_dir, [db_info.cname{c}, num2str(i), '.jpg']);
            imwrite(imr, savef);
        catch
            ['---->', imf]
            continue;
        end
        
        %%
        names{end+1} = ['/train/', db_info.cname{c}, '/', db_info.cname{c}, num2str(i), '.jpg'];
        labels{end+1} = c;
        idx = idx + 1;
    end
end


imdb.images.id = 1:numel(names) ;
imdb.images.name = names ;
imdb.images.set = ones(1, numel(names)) ;
imdb.images.label = labels ;

% -------------------------------------------------------------------------
%                                                         Validation images
% -------------------------------------------------------------------------

fprintf('searching val images ...\n') ;
names = {} ;
labels = {} ;

for c = 1:db_info.nclass
    
    sub_dir = [out_dir, '/val/', db_info.cname{c}];
    mkdir(sub_dir);
    ndb = min(length(db_info.path{c}), nmax);
  
    ntrain = floor(ndb*ptrain);
    nstart = 1+ntrain;
    nval = floor(ndb*pval);
    idx = 1;
    for i = nstart:nstart+nval-1
        if idx>nmax; break;end
        imf = db_info.path{c}{i}
        try
            im = imread(imf);
            imr = imresize(im, msize);
            savef = fullfile(sub_dir, [db_info.cname{c}, num2str(i), '.jpg']);
            imwrite(imr, savef);
        catch
            continue;
        end
        
        %%
        names{end+1} = ['/val/', db_info.cname{c}, '/', db_info.cname{c}, num2str(i), '.jpg'];
        labels{end+1} = c;
        idx = idx + 1;
    end
end

imdb.images.id = horzcat(imdb.images.id, (1:numel(names)) + 1e7 - 1) ;
imdb.images.name = horzcat(imdb.images.name, names) ;
imdb.images.set = horzcat(imdb.images.set, 2*ones(1,numel(names))) ;
imdb.images.label = horzcat(imdb.images.label, labels) ;

% -------------------------------------------------------------------------
%                                                               Test images
% -------------------------------------------------------------------------

fprintf('searching test images ...\n') ;
names = {} ;
labels = {} ;

for c = 1:db_info.nclass
    
    sub_dir = [out_dir, '/test/', db_info.cname{c}];
    mkdir(sub_dir);
    ndb = min(length(db_info.path{c}), nmax);
   
    ntrain = floor(ndb*ptrain);
    nval = floor(length(db_info.path{c})*pval);
    nstart = ntrain+nval+1;
    ntest = floor(ndb*ptest);
    idx = 1;
    for i = nstart:nstart+ntest-1
        if idx>nmax; break;end
        try
            imf = db_info.path{c}{i}
            im = imread(imf);
            imr = imresize(im, msize);
            savef = fullfile(sub_dir, [db_info.cname{c}, num2str(i), '.jpg']);
            imwrite(imr, savef);
        catch
            continue;
        end
        
        %%
        names{end+1} = ['/test/', db_info.cname{c}, '/', db_info.cname{c}, num2str(i), '.jpg'];
        labels{end+1} = c;
        idx = idx + 1;
    end
end

imdb.images.id = horzcat(imdb.images.id, (1:numel(names)) + 2e7 - 1) ;
imdb.images.name = horzcat(imdb.images.name, names) ;
imdb.images.set = horzcat(imdb.images.set, 3*ones(1,numel(names))) ;
imdb.images.label = horzcat(imdb.images.label, labels) ;

%%
imdb
save(mat_file, 'imdb')
