FROM eduardrosert/python-k8s-controller:7f8803c7a65c9b9d836e58243c0aea566ecd46c6 as base

# WORKAROUND: copy the download script
COPY ./opendata-downloader.py /

# copy the download script
COPY ./download_and_redeploy.sh /

# run script
CMD ./download_and_redeploy.sh