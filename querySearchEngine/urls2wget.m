function urls2wget(urls, listfile)

%wget $url -T 5 -t 5 -O $fuile
fptr = fopen(listfile, 'w');

for i = 1:length(urls)
    fprintf(fptr, 'wget ''%s'' -T 5 -t 5 \n', urls{i});
end

fclose(fptr);