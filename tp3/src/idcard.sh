#!/bin/bash

#Simple script for IdCard
index=1
len=$(ss -lnp4H | wc -l)
echo "Machine name : $(hostnamectl | grep hostname | cut -d ' ' -f4) "
echo "OS $(cat /etc/os-release | grep 'NAME=' -m 1 | cut -d '"' -f2) and kernel version is$(hostnamectl | tr -s ' ' | grep Kernel | cut -d ':' -f 2)"
echo "IP : $(ip a | grep 'inet ' | tr -s ' '| cut -d '/' -f1 | cut -d ' ' -f3 | tail -n 1)"
echo "RAM : $(free -t -h | grep Total | tr -s ' ' | cut -d ' ' -f4) memory available on $(free -t -h | grep Total | tr -s ' ' | cut -d ' ' -f2) total memory"
echo "Disk : $(df -h | grep ' /$' | tr -s ' ' | cut -d ' ' -f4) space left"
echo "Top 5 processes by RAM usage : "
for i in $(seq 1 5)
do 
   echo "  - $(ps -e -o cmd= --sort=-%mem | head -n${i} | tail -n+${i} | cut -d ' ' -f1)"
done
echo "Listening ports : "
while [[ ${index} -le ${len} ]]
do 
  echo "  - $(ss -ln4Hp | tr -s ' '| cut -d' ' -f5 | cut -d':' -f2 | head -n ${index} | tail -n +${index}) $(ss -ln4Hp | tr -s ' '| cut -d' ' -f1 | head -n ${index} | tail -n +${index}) : $(ss -ltun4Hp | tr -s ' ' | cut -d'"' -f2 | head -n ${index} | tail -n +${index})"
index=$(( index + 1 ))
done


curl https://cataas.com/cat --output cat_pic 2> /dev/null
_file_extension="$(file cat_pic| cut -d' ' -f2)"

if [[ "${_file_extension}" == PNG ]]
then
   _extension='.png'
elif [[ "${_file_extension}" == JPEG ]]
then 
   _extension='.jpeg'
elif [[ "${_file_extension}" == GIF ]]
then
  _extension='.gif'
else
   echo"File type unknow"
   exit 1
fi
_file_name="cat_pic"
_file="${_file_name}${_extension}"
mv "cat_pic" "${_file}"
echo "Here is your random cat: ./${_file}"
