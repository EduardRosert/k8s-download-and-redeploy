FROM eduardrosert/python-k8s-controller:96254470702dc1395899eb95ca4ed66e923fb0c138 as base

# copy the download script
COPY ./download_and_redeploy.sh /

# WORKAROUND: get the download script from git
RUN wget https://github.com/EduardRosert/docker-dwd-open-data-downloader/blob/master/opendata-downloader.py

# run script
CMD ./download_and_redeploy.sh