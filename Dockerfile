# build
FROM python:3.8-slim as build-stage

COPY requirements.txt /root/

RUN     apt-get update && \
        apt-get install -y --no-install-recommends wget curl unzip imagemagick ffmpeg && \
        apt-get install -y --no-install-recommends python3-dev python3-pip python-twisted python3-dev python3-setuptools && \
        apt-get install -y --no-install-recommends build-essential && \
        apt-get install -y --no-install-recommends libxml2-dev python-lxml python-requests

# deploy
FROM jrottenberg/ffmpeg:4.2-scratch AS ffmpeg
FROM python:3.8-slim

COPY --from=ffmpeg / /
COPY --from=build-stage /root/requirements.txt /root

COPY --from=build-stage /usr/lib/x86_64-linux-gnu/*.so.* /usr/lib/x86_64-linux-gnu/
COPY --from=build-stage /lib/x86_64-linux-gnu/*.so.* /lib/x86_64-linux-gnu/

RUN apt-get update && \
	apt-get install -y tini wget curl fonts-ipafont git && \
	pip3 install --upgrade pip && \
	pip3 install -r /root/requirements.txt && \
	rm -rf /root/.cache/pip && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*


COPY default_scrapyd.conf /usr/local/lib/python3.8/site-packages/scrapyd

WORKDIR /project

CMD scrapyd
