#!/bin/sh

#
if [ $# -ne 2 ] ; then
	echo "Usage: do.sh [input dir] [name]"
	exit 1
fi

inDir="$1"
outDir="$2"
echo "input: $inDir"
echo "output: $outDir"

#
$x=0
for file in $inDir/*.jpg

do
	echo $file
	((x+=1))
	mv "$file" "$inDir/${outDir}_$x.jpg"
done
