#!/bin/sh 

#Script should be safe as long as DIR and FILE don't point to anything valuable 
DIR=/etc/X11/xorg.conf.d 
FILE=01-laptop.conf 

TEST=$(lspci | grep -c " VGA ") 

#Check TEST against number of gpus including egpu 
if ([ $TEST -eq 2 ]); then 
   #eGPU Connected 
   echo "eGPU Connected, removing laptop config" 
   if ([ -e $DIR/$FILE ]); then 
       rm $DIR/$FILE 
   fi 
else 
   #No eGPU or unexpected number/output 
   echo "No eGPU found, switching to laptop graphics" 
   if ([ -e $DIR/$FILE ]); then 
       break 
   else 
       if ([ -e $DIR/inactive/$FILE ]); then 
           cp $DIR/inactive/$FILE $DIR/$FILE 
       fi 
   fi 
fi