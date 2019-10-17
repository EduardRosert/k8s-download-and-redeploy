FROM eduardrosert/python-k8s-controller:7f8803c7a65c9b9d836e58243c0aea566ecd46c6 as base

# copy the download script
COPY ./download_and_redeploy.sh /

# WORKAROUND: get the download script from git
RUN wget https://github.com/EduardRosert/docker-dwd-open-data-downloader/blob/master/opendata-downloader.py

# run script
CMD ./download_and_redeploy.sh