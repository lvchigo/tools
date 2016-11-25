#Path
path_src='/home/chigo/image/test/'
path_save='/home/chigo/working/research/similardetect/v1.0.0/bin/sv/'

#Label
a=(street_img)

#detect similar img
rm -rf keyfile
mkdir keyfile

#merge file to one
rm -rf $path_save
mkdir $path_save

for((i=0;i<1;i++))
 do
  b=${a[$i]}
  echo $b

  find $path_src/$b/ -name "*.jpg" >list_$b.txt

  rm -rf $path_save/$b/
  mkdir $path_save/$b/

  #Demo -simdetectmuti ImageList.txt keyFilePath savePath saveName nThreads BinSaveFeat BinReSizeImg BinUseName
  #BinReSizeImg:2-resize to 512,1-resize to 256*256,0-no resize
  ./Demo -simdetectmuti list_$b.txt keyfile/ $path_save/$b/ $b.161125 4 1 2 0

  #rm -rf keyfile
done

#rm -rf keyfile
rm list_*.txt




