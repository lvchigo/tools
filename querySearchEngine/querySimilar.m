function urls = querySimilar(url_img)

%
urls = [];
url_template = 'http://shitu.baidu.com/n/listpc?queryImageUrl=%s#tab=similar';
url = sprintf(url_template, url_img);
try
html = urlread(url); %'Charset','UTF-8
pos = strfind(html,'simiData');
if length(pos) < 1
    return;
end
catch
    return;
end

html = html(pos:end);
sstart = 'objURL\x22:\x22';
pstart = strfind(html, sstart);
pend = strfind(html, '\x22,\x22thumbURL');
for i = 1:length(pstart)
    url = html(pstart(i)+length(sstart):pend(i)-1);
    urls{end+1} = strrep(url, '\\\/', '/');
end
