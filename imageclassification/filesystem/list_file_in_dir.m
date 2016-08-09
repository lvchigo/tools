function file_list = list_file_in_dir(file_dir, file_type)


file_list = {};
file_types = regexp(file_type, '\|', 'split');


for i = 1:length(file_types)

    frames = dir( fullfile(file_dir, char(file_types(i))) );
    if ( length(frames)<1 )
        continue;
    end
    names_set = struct2cell(frames);
    names = names_set(1, :);
    for j = 1:length(names)
        file_list = [file_list, fullfile(file_dir, char(names(j))) ];
    end
end