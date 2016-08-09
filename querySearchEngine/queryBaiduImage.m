function result = queryBaiduImage(original_keywords, image_count, site)

% tn=result_pageturn

if ~exist('original_keywords','var')
    original_keywords = '兔子';
end
if ~exist('image_count','var')
    image_count = 100;
end
if ~exist('site','var')
    site = '';
else
    site = ['site%3A', site];
end

keywords = regexprep(original_keywords,' ','+');
keywords = java.net.URLEncoder.encode(keywords,   'utf-8');
keywords = char(cell(keywords));
T = 5;

pn = 0;
result = [];
while(1)
    url_template = 'http://image.baidu.com/i?tn=baiduimagejson&ie=utf-8&width=&height=&face=0&istype=2&word=%s%s&pn=%d';
    url = sprintf(url_template,keywords, site, pn);
    try
    html = urlread(url, 'Timeout', T); %'Charset','UTF-8
    
    sstart = '"objURL":"';
    pstart = strfind(html, sstart);
    send = '",    "fromURL"';
    pend = strfind(html, send);
    
    if  pn > 1.2*image_count, break; end
    if length(pstart) < 1, pn = pn + 10; continue; end;
    for i = 1:length(pstart)
        result{end+1} = html(pstart(i)+length(sstart):pend(i)-1);
    end
    
    %[~, uID ]=unique(result);
    %result = result(uID);
    if length(result) > image_count 
        break;
    end
    
    pn = pn + length(pstart);
    catch
        % do nothing
    end
end


function result = queryBaiduImageJson(original_keywords, image_count, site)

% tn=result_pageturn

if ~exist('original_keywords','var')
    original_keywords = '兔子';
end
if ~exist('image_count','var')
    image_count = 100;
end
if ~exist('site','var')
    site = '';
else
    site = ['site%3A', site];
end

keywords = regexprep(original_keywords,' ','+');
keywords = java.net.URLEncoder.encode(keywords,   'utf-8');
keywords = char(cell(keywords));
T = 5;

pn = 0;
result = [];
while(1)
    url_template = 'http://image.baidu.com/i?tn=baiduimagejson&ie=utf-8&width=&height=&face=0&istype=2&word=%s%s&pn=%d';
    url = sprintf(url_template,keywords, site, pn)
    try
    html = urlread(url, 'Timeout', T); %'Charset','UTF-8
    data = parse_json(html);
    
    if  pn > 2*image_count, break; end
    if length(data) < 1, pn = pn + 10; continue; end;
    if length(data{1,1}.data) < 2, pn = pn + 10; continue; end;
    
    for i = 1:length(data{1,1}.data)-1
        result{end+1} = data{1,1}.data{1,i}.objURL; % thumbURL
    end
    %[~, uID ]=unique(result);
    %result = result(uID);
    if length(result) > image_count 
        break;
    end
    
    pn = pn + length(data{1,1}.data) - 1;
    catch
        % do nothing
    end
end