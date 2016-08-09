function result = queryBingWeb(original_keywords, image_count)

% example usage:  result = queryBingWeb();

if ~exist('original_keywords','var')
    original_keywords = '兔子';
end
if ~exist('image_count','var')
    image_count = 100;
end
T = 5;
keywords = regexprep(original_keywords,' ','+');
keywords = java.net.URLEncoder.encode(keywords,   'utf-8');
keywords = char(cell(keywords));
chunk = 100;

url_template = 'http://cn.bing.com/images/async?q=%s&async=content&first=%d&count=%d';

cnt = 0;
result = [];
for first=0:chunk:image_count
    try
    url = sprintf(url_template,keywords,first,chunk);
    html = urlread(url, 'Timeout', T); %'Charset','UTF-8
    pos = strfind(html,'<div class="imgres">');
    html = html(pos+20:end);
    items = regexp(html, '</div>', 'split');
    items = items(1:end-1);
  
    
    catch
        continue;
    end
    
    for itemID=1:length(items)
        try
        if(length(items{itemID})) < 1
            continue;
        end
        s = strfind(items{itemID},'m="{')+3;
        e = strfind(items{itemID},'}"');
        info = regexprep(items{itemID}(s:e),'&quot;','"');
        %{
        s = strfind(items{itemID},'t1="')+4;
        e = s + strfind(items{itemID}(s:end),'"')-2;
        t1 = items{itemID}(s:e);
        
        s = strfind(items{itemID},'<img')+4; s=s(1);
        e = s+strfind(items{itemID}(s:end),'/>')-2;
        img = items{itemID}(s:e);
        
        s = strfind(img,'http://'); s=s(1);
        e = s+strfind(img(s:end),'"')-2;        
        thumbnail = img(s:e);
        %}
        s = strfind(info,'imgurl:"')+8; 
        if length(s) < 1
            continue;
        end
        s=s(1);
        e = s+strfind(info(s:end),'"')-2;        
        url = info(s:e);        
        
        cnt = cnt +1;
        %{
        result{cnt,1} = [info(1:end-1) ',"query":"' original_keywords '","title":"' t1 '","thumbnail":"' thumbnail '"}'];
        result{cnt,2} = url;
        result{cnt,3} = thumbnail;
        %}
        result{end+1} = url;
        
        catch
            continue;
        end
    end
end

%[~, uID ]=unique(result);
%result = result(uID);