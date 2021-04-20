asy -f png solar.asy -globalwrite
cat solar_movie/solar_*png | ffmpeg -f image2pipe -r 30 -i - -vcodec libx264 video.mkv -y