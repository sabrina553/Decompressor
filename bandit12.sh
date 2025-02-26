#!/bin/bash
# if tmp directory doesn't exist. will create it to store files as we decode multipe times
if [ ! -d "tmp/" ]; then $(mkdir tmp/); fi
#filename incrementer
n=0
#filename should be the last argument made when script is called (bad code? trivago)
input_file="${@: -1}"
#create flags {h}
while getopts h option
do
    case "${option}" in
        #reverts a hexdump
        h) 
            $(xxd -r $input_file > tmp/$n)
            input_file=tmp/$n;;        
    esac
done
#loop decompressers until undetermined (non-compressed*) file is extracted
while true; do
    let "n++" 
    #use file command to determine file type
    type="$(file  $input_file | awk '{print $2}')"
    echo $type    
    #switch between known file-type decompressions
    case $type in 
        gzip)
            $(zcat $input_file > tmp/$n)
            input_file="tmp/$n";;
        bzip2)
            $(bzip2 -cdf $input_file > tmp/$n)
            input_file="tmp/$n";;
        POSIX)            
            var=$(tar xvf $input_file -C tmp/)
            $(cp tmp/$var tmp/$n && rm tmp/$var)
            input_file="tmp/$n";;
        *)
            cat $input_file
            break;;
    esac   
done
# IF    //known decompressor//  OF
#ASCII // gzip bzip2 POSIX // ASCII