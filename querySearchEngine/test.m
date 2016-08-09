function test

rt_dir = pwd;
db_dir = '/home/tangyuan/ssd/Data/bingimage';
image_count = 5000;

query = '兔子';
urls = queryBingWeb(query, image_count);
query_dir = [db_dir, '/', query];
mkdir(query_dir);
sh_file = [query_dir, '/download.sh'];
urls2wget(urls, sh_file);
%dos(['cd ', query_dir, '&& bash ', sh_file, ' &']);
