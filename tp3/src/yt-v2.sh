#!/bin/bash

for (( ; ; ))
do
  if [[ !  -d  "/srv/yt/downloads" ]]
  then 
    echo "directory for download does not exit create him here /srv/yt/downloads "
    exit 1
  fi
  if [[ ! -d "/var/log/yt/" ]]
  then 
    exit 1
  fi

  video="$( cat /srv/yt/video.txt | head -n1)"
  sed -i '1d' /srv/yt/video.txt
  title="$( youtube-dl -title ${video} 2> /dev/null)"
  title=${title// /_}
  mkdir /srv/yt/downloads/${title}
  youtube-dl -o /srv/yt/downloads/${title}/${title}.mp4 ${video} > /dev/null
  echo "Video ${video} was downloaded."
  echo "File path: /srv/yt/downloads/${title}/${title}.mp4"
  mkdir /srv/yt/downloads/${title}/description
  youtube-dl --get-description ${video} > /srv/yt/downloads/${title}/description/${title}.description 2> /dev/null
  date +"%Y-%m-%d %T"" Video ${video} was downloaded. File path : /srv/yt/downloads/${title}/${title}.mp4" >> /var/log/yt/download.log
  sleep 5
done
