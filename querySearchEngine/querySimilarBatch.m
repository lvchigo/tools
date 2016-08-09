function result = querySimilarBatch(url_img, image_count)

if ~exist('image_count','var')
    image_count = 3000;
end
%
%url_img = 'http://www.sd.xinhuanet.com/news/2008-01/29/xin_41301052917353752373956.jpg';
result = [];
batches = 20;
count = 1;
nstart = 31;
while(1)
    urls = querySimilar(url_img);
    result = [result, urls];
    for i = 1:length(urls)
        url = urls{i}
        res = querySimilar(url);
        result = [result, res];
    end
    [~, uID ]=unique(result);
    result = result(uID);
    if length(result)>image_count || count>batches
        break;
    end
    
    url_img = result{nstart};
    nstart =  nstart + 1;
    count = count + 1;
end

