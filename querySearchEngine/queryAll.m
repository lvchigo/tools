function result = queryAll(original_keywords, image_count)

if ~exist('original_keywords','var')
    original_keywords = '帽子';
end
if ~exist('image_count','var')
    image_count = 2000;
end

result = [];
disp(['query ' original_keywords ' by baidu image']);
baidu = queryBaiduImage(original_keywords, image_count);
result = [result baidu];
length(result)
disp(['query ' original_keywords ' by bing image']);
bing = queryBingWeb(original_keywords, image_count);
result = [result bing];
length(result)
disp(['query ' original_keywords ' by sogou image']);
sogou = querySogouImage(original_keywords, image_count);
result = [result sogou];
length(result)

disp('unique result');
[~, uID ]=unique(result);
result = result(uID);
length(result)