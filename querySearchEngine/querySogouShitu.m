function result = querySogouShitu(url_img, image_count)

%http://pic.sogou.com/ris?query=&flag=1&scope=all&page=2
if ~exist('url_img','var')
    url_img = 'http://imgsrc.baidu.com/forum/w%3D580/sign=29379f7a37fae6cd0cb4ab693fb20f9e/a8c9bb119313b07e749c2e450ed7912397dd8c11.jpg';
end
if ~exist('image_count','var')
    image_count = 100;
end

pn = 1;
result = [];
while(1)
    url_template = 'http://pic.sogou.com/ris?query=%s&flag=1&scope=all&page=%d';
    url = sprintf(url_template, url_img, pn)
    html = urlread(url); %'Charset','UTF-8
    
    sstart = '"pic_url":"';
    pstart = strfind(html, sstart);
    send = '","width"';
    pend = strfind(html, send);
    for i = 1:length(pstart)
        result{end+1} = html(pstart(i)+length(sstart):pend(i)-1);
    end
    [~, uID ]=unique(result);
    result = result(uID);

    if length(result)> image_count || pn>100
        break;
    end
    pn = pn + 1;
    
end


length(result)