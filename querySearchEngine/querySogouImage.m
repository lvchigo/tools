function result = querySogouImage(original_keywords, image_count, site)

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
    site = ['+site%3A', site];
end

keywords = regexprep(original_keywords,' ','+');
keywords = java.net.URLEncoder.encode(keywords,   'utf-8');
keywords = char(cell(keywords));

T = 5;
pn = 1;
result = [];
while(1)
    try
    url_template = 'http://pic.sogou.com/pics?query=%s%s&page=%d';
    url = sprintf(url_template,keywords, site, pn);
    html = urlread(url, 'Timeout', T); %'Charset','UTF-8
    
    sstart = '"pic_url":"';
    pstart = strfind(html, sstart);
    send = '","similarUrlFirst"';
    pend = strfind(html, send);
    for i = 1:length(pstart)
        result{end+1} = html(pstart(i)+length(sstart):pend(i)-1);
    end
    %[~, uID ]=unique(result);
    %result = result(uID);
    catch
        %do nothing
    end
    if length(result)> image_count || pn>100
        break;
    end
    pn = pn + 1;
    
end

