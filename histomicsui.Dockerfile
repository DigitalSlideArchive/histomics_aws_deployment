FROM ubuntu:22.04
LABEL maintainer="Kitware, Inc. <kitware@kitware.com>"

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=C.UTF-8

RUN apt-get update && apt-get install -qy \
    gcc \
    libpython3-dev \
    git \
    libldap2-dev \
    libsasl2-dev \
    python3-pip \
    curl \
&& apt-get clean && rm -rf /var/lib/apt/lists/* \
&& python3 -m pip install --upgrade --no-cache-dir \
    pip \
    setuptools \
    setuptools_scm \
    wheel

RUN curl -sL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -qy nodejs

RUN pip install --find-links https://girder.github.io/large_image_wheels \
    gunicorn \
    'large-image[sources]>=1.32.4.a122' \
    'girder>=5.0.0a6' \
    'girder-plugin-worker>=5.0.0a8.dev48' \
    'girder-sentry>=5.0.0a6' \
    'girder-slicer-cli-web>=5.0.0a8.dev2' \
    'girder-large-image>=1.32.4a122' \
    'girder-large-image-annotation>=1.32.4a122'

# TODO once Histomics has girder 5 packages on pypi, use that instead
RUN cd /opt && \
    git clone https://github.com/DigitalSlideArchive/HistomicsUI && \
    cd /opt/HistomicsUI && \
    git checkout girder-5 && \
    cd ./histomicsui/web_client && npm i && npm run build && cd ../.. && \
    pip install --no-cache-dir -e .[analysis]

WORKDIR /opt/HistomicsUI
