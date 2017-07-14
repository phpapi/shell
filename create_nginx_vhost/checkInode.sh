#!/bin/bash

#Inspcet Inode : If the free INODE is less than 200, the message is sent to the wl

#Tue Aug  2 10:21:29 CST 2016

PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/wl/bin

export PATH

for FreeInode in $(df -i | grep -v "Filesystem" | awk '{print $4}')
do
  if [[ $FreeInode < 200 ]];then
    echo -e "$(df -i | grep "$FreeInode")" > /service/script/.FreeInode
    mail -s "FreeInode Warning" wl < /service/script/.FreeInode
  fi
done