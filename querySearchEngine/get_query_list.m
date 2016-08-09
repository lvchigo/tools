function query = get_query_list(query_list)


fptr = fopen(query_list, 'r');
query = {};
while ~feof(fptr)
    
    query = [query; fgetl(fptr)];
    
end
fclose(fptr)