function keywords = queryShitu(url_img)

%
%url_img = 'http%3A%2F%2Fb.hiphotos.baidu.com%2Fshitu%2Fpic%2Fitem%2Fb151f8198618367af336aafc2a738bd4b31ce550.jpg';
keywords = [];
url_template = 'http://shitu.baidu.com/n/searchpc?queryImageUrl=%s';
url = sprintf(url_template, url_img);
html = urlread(url); %'Charset','UTF-8
pos = strfind(html,'keyword\x22:\x22');
if length(pos) < 1
    return;
end


for i = 1:length(pos)
    
    p = pos(i);
    key = html(p+16:end);
    q = strfind(key,'\x22,');
    uc_str = key(1:q(1)-1);
    chstr = unicode2chs(uc_str);
    if length(chstr) < 1
        continue;
    end
    keywords{end+1} = chstr;
    
end



