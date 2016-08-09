function demo_similar

%bichon http://inimg02.jiuyan.info/in/2015/01/26/F92D2983-7CC7-5BE1-77AE-CB4AA04AB236.jpg
%samoyed http://inimg02.jiuyan.info/in/2015/01/31/6DB730A6-1D58-95D8-7675-D139206385FD.jpg
%sticker http://inimg02.jiuyan.info/in/2015/01/17/5B8BA961-7EC5-6413-3F1F-2AB2F867FE85.jpg
url_img = 'http://inimg02.jiuyan.info/in/2015/01/17/5B8BA961-7EC5-6413-3F1F-2AB2F867FE85.jpg';
result = querySimilarBatch(url_img);
urls2wget(result, '/home/tangyuan/ssd/Data/similar/sticker.sh');