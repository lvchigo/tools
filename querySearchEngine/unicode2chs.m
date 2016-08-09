function chstr = unicode2chs(uc_str)
%Unicode To chinese
%uc_str = '\\u6d77\\u6d0b';

chstr = '';
uc_cell = regexp(uc_str, '\\\\u', 'split');
if length(uc_cell)<2
    return;
end

for i = 2:length(uc_cell)
    ch = char(java.lang.Integer.parseInt(uc_cell(i),16));
    chstr = [chstr, ch];
end
