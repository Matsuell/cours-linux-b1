#!/bin/bash

if [[ ${1} == '' ]]
then
  echo "you should give video link"
  exit 1
fi

if [[ !  -d  "/srv/yt/downloads" ]]
then 
  echo "directory for download does not exit create him here /srv/yt/downloads "
  exit 1
fi

if [[ ! -d "/var/log/yt/" ]]
then 
  exit 1
fi
title="$( youtube-dl -title ${1} 2> /dev/null)"
title=${title// /_}
mkdir /srv/yt/downloads/${title}
youtube-dl -o /srv/yt/downloads/${title}/${title}.mp4 ${1} > /dev/null
echo "Video ${1} was downloaded."
echo "File path: /srv/yt/downloads/${title}/${title}.mp4"
mkdir /srv/yt/downloads/${title}/description
youtube-dl --get-description ${1} > /srv/yt/downloads/${title}/description/${title}.description 2> /dev/null
date +"%Y-%m-%d %T"" Video ${1} was downloaded. File path : /srv/yt/downloads/${title}/${title}.mp4" >> /var/log/yt/download.log
