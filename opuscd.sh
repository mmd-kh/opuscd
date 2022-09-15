#!/bin/bash

if [ ! -z "$(grep -im 1 'REM GENRE*' *.cue | sed 's/"//g' | cut -d ' ' -f 1,2 --complement)" ] &> /dev/null; then
	echo $(grep -im 1 'REM GENRE*' *.cue | sed 's/"//g' | cut -d ' ' -f 1,2 --complement)
else
	read -p "please enter the genre: " genre
fi
#echo $(grep -im 1 'REM GENRE*' *.cue | sed 's/"//g' | cut -d ' ' -f 1,2 --complement)
read -p "is the above the correct genre? [y/n]: " answer
case "$answer" in 
	[yY] | [yY][eE][sS])
		genre=$(grep -im 1 'REM GENRE*' *.cue | sed 's/"//g' | cut -d ' ' -f 1,2 --complement)
		;;
	[nN] | [nN][oO])
		read -p "please enter the genre: " genre
		;;
	*)
		echo "please rerun the script and enter y/yes or n/no"; exit
esac

if [ ! -z "$(find -iname *.flac)" ] &> /dev/null; then
	FILE=flac
elif [ ! -z "$(find -iname *.ape)" ] &> /dev/null; then 
	FILE=ape
elif [ ! -z "$(find -iname *.alac)" ] &> /dev/null; then 
	FILE=alac
else 
	read -p "please enter the file extension: " FILE
fi

if [ ! -z "$(grep -i 'REM DATE' *.cue)" ] &> /dev/null; then 
	DATE=$(grep 'REM DATE' *.cue | awk '{ print $NF }')
else 
	read -p "please enter the date: " DATE
fi

curdir="${PWD##*/}"; mkdir "$curdir"
shnsplit -f *.cue -t 'shnsplit %n. %t' -o flac *.$FILE; mv shnsplit*.flac "$curdir"
cp -r Scans scans scan Scan Covers covers cover Cover *.jpg *.png *.jpeg *.cue "$curdir"; cd "$curdir"

if hash cuetag &>/dev/null; then
	cuetag *.cue *.flac
else
	cuetag.sh *.cue *.flac
fi

alname=$(grep -oim 1 'TITLE ".*"' *.cue | sed 's/"//g' | cut -d ' ' -f 1 --complement)
rm *.cue

for i in *.flac
do ffmpeg -i "$i" -c:a libopus -b:a 160k -metadata genre="$genre" -metadata year="$DATE" "${i%.*}.opus"
done; rm *.flac

for a in shnsplit*.opus 
do mv "$a" "`echo "$a" | sed 's/shnsplit //g'`"
done

echo 'enjoy listening to' $alname $USER ':D'
