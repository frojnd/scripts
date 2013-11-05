#!/bin/bash
exec 9>log.txt
BASH_XTRACEFD=9
PS4='+$BASH_SOURCE:$FUNCNAME:$LINENO:'
set -x

shopt -s nullglob
shopt -s nocaseglob
# enables extended globs for use with regular expressions
shopt -s extglob

#touch 'AAA BBB'; r() { local a="${1// /_}"; mv "$1" "${a,,}"; }; r 'AAA BBB'; ls
#fixing your rename()
#faster because not any fork() at all dont use command Substitution and pipelines,
# also not any external programs like 'tr'

# 4:3 format second array numbers
num480=480
num1200=1200
num2112=2112
num3000=3000
num43="399x299"

# 3:2 format second array numbers
num424=424
num1064=1064
num1880=1880
num2664=2664
num32="399x264"

# 16:10 format second array numbers
num360=360
num1080=1080
num1584=1584
num2248=2248
num1610="399x224"

# quality global variable
quality=85

# Function rename rename all characters to lower case and replaces white
# spaces with underscores
function rename {
    for i in *; do
        mv "$i" $(echo $i | tr ' ' '_' | tr '[:upper:]' '[:lower:]') 
    done
}

# For testing. It copy exisiting .JPG files with new names
<<'comment'
function renameSizes {
    for i in P*.JPG; do
        b=${num480}$i        
        echo $b
        cp $i $b
    done
}
comment

# For testing. imagemagick converts pictures that mathces pattern
<<'comment2'
function assignSizes {
    for file in *.JPG; do
        if [[ $file == $num1200* ]]; then
            convert -resize $num43 -quality $quality $file obd_joz_$file;
        fi
        if [[ $file == $num480* ]]; then
            convert -resize $num43 -quality $quality $file obd_joz_$file;
        fi
    done
}
comment2

# iz zips all files starting with obd_joz_
function zipObdfiles {
    zip pic_joz_"${PWD##*/}".zip obd_joz_* 
}

# It resizes pictures with the help of imagemagick program
function resizeFunction {
    # function rename must be called first
    rename
    for i in *.jpg *.JPG *.jpeg *.JPEG; do
        # height of the picture is retained with exiv2 and awk program
        # we use it later for comparison
        size=$(exiv2 "$i" | awk '/Image size/ { print $6 }'); 

        # for all 4:3 standard formats
        # if size of the current picture matches any of the numbers we resize it
        if ((size == num1200 || size == num480 || size == num2112 || size == num3000)); then
            convert -resize $num43 -quality $quality $i obd_joz_$i;
        # if there is no match we convert it to 399x299 4:3 format 
        else
            convert -resize $num43 -quality $quality $i obd_joz_$i;
        fi
        # for all 3:2 standard formats
        if ((size == num424 || size == num1064 || size == num1880 || size == num2664)); then
            convert -resize $num32 -quality $quality $i obd_joz_$i;
        else
            convert -resize $num43 -quality $quality $i obd_joz_$i;
        fi
        # for all 16:10 standardstandard formats
        if ((size == num360 || size == num1080 || size == num1584 || size == num2248)); then
            convert -resize $num1610 -quality $quality $i obd_joz_$i;
        fi
    done

    # zip function zipps all files that were resized
    zipObdfiles

    # move pic_joz_*.zip to parent directory
    mv pic_joz_*.zip ../
}

# unzip all zip files and go into a unzipped directory and there run resize function
function main {
    # zip is added to the glob
    # iterates trhroug each zip except pic_joz_*.zip file
    for i in !(pic_joz_*).zip; do
        unzip "$i" && cd "${i/.zip}" 
        resizeFunction
        cd ../
    done

    # in the end all directories are removed except .zip files remains
    rm -r !(*.zip|*.txt)
}

main
