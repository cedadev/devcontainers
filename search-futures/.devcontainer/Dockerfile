FROM mcr.microsoft.com/devcontainers/anaconda:0-3

# Copy environment.yml (if found) to a temp location so we update the environment. Also
# copy "noop.txt" so the COPY instruction does not fail if no environment.yml exists.
COPY environment.yml* .devcontainer/noop.txt /tmp/conda-tmp/
RUN if [ -f "/tmp/conda-tmp/environment.yml" ]; then \
    umask 0002 && \
    /opt/conda/bin/conda env update -n base -f /tmp/conda-tmp/environment.yml ; \
    fi && \
    rm -rf /tmp/conda-tmp

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

# Include a custom entrypoint that will execute startup services
# COPY .devcontainer/docker-entrypoint.sh /usr/local/bin/

ENV DATABASE=1
ENV SERVER=1
ENV PYSTAC=1
ENV PYSTAC_CLIENT=1
ENV ESGF_CLIENT=1

ARG ELK_VERSION=7.17.4
ARG STAC_FASTAPI_ELASTICSEARCH_VERSION=atod
ARG PYSTAC_VERSION=asset-search
ARG PYSTAC_CLIENT_VERSION=asset-search
ARG ESGF_CLIENT_VERSION=master

RUN mkdir /workspaces

# Install elasticsearch database
RUN if [ "$DATABASE" = "1" ] ; then \
    mkdir /elastic && \
    # Download the elasticsearch code archive
    curl -fsSL -o elasticsearch.tar.gz https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$ELK_VERSION-linux-x86_64.tar.gz && \
    curl -fsSL -o elasticsearch.tar.gz.sha https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$ELK_VERSION-linux-x86_64.tar.gz.sha512 && \
    # Check checksum
    echo "$(awk '{print $1}'  elasticsearch.tar.gz.sha)  elasticsearch.tar.gz" > elasticsearch.tar.gz.sha && \
    shasum -a 512 -c elasticsearch.tar.gz.sha && \
    tar -xf elasticsearch.tar.gz  && \
    cp -r elasticsearch-$ELK_VERSION/* /elastic/. && \
    rm -rf elasticsearch* && \
    chown -R vscode:vscode /elastic ; \
    fi

# Install stac-fastapi-elasticsearch
RUN if [ "$SERVER" = "1" ] ; then \
    cd /workspaces/ && \
    git clone -b $STAC_FASTAPI_ELASTICSEARCH_VERSION https://github.com/cedadev/stac-fastapi-elasticsearch && \
    cd stac-fastapi-elasticsearch/ && \
    pip install -r requirements.txt && \
    pip install django-flexi-settings==0.1.1 && \
    pip install -e .[server,dev] && \
    # Mark repo as safe
    git config --system --add safe.directory /workspaces/stac-fastapi-elasticsearch && \
    # Change directory ownership
    chown -R vscode:vscode /workspaces/stac-fastapi-elasticsearch ; \
    fi

# Install Pystac
RUN if [ "$PYSTAC" = "1" ] ; then \
    cd /workspaces/ && \
    git clone -b $PYSTAC_VERSION https://github.com/cedadev/pystac && \
    cd pystac/ && \
    pip install -r requirements-dev.txt && \
    pip install -e . --no-deps && \
    # Mark repo as safe
    git config --system --add safe.directory /workspaces/pystac && \
    # Change directory ownership
    chown -R vscode:vscode /workspaces/pystac ; \
    fi

# Install Pystac-client
RUN if [ "$PYSTAC_CLIENT" = "1" ] ; then \
    cd /workspaces/ && \
    git clone -b $PYSTAC_CLIENT_VERSION https://github.com/cedadev/pystac-client && \
    cd pystac-client/ && \
    perl -p -i -w -e 's/^pystac==1.4.0/#pystac==1.4.0/g' requirements-min.txt && \
    pip install -r requirements-min.txt && \
    pip install -r requirements-dev.txt && \
    pip install -e . --no-deps  && \
    # Mark repo as safe
    git config --system --add safe.directory /workspaces/pystac-client && \
    # Change directory ownership
    chown -R vscode:vscode /workspaces/pystac-client ; \
    fi

#Install stac-fastapi-elasticsearch
RUN if [ "$ESGF_CLIENT" = "1" ] ; then \
    cd /workspaces/ && \
    git clone -b $ESGF_CLIENT_VERSION https://github.com/cedadev/esgf-stac-client && \
    cd esgf-stac-client/ && \
    pip install -r requirements.txt && \
    pip install -r requirements_dev.txt && \
    pip install -e . && \
    # Mark repo as safe
    git config --system --add safe.directory /workspaces/esgf-stac-client && \
    # Change directory ownership
    chown -R vscode:vscode /workspaces/esgf-stac-client ; \
    fi

# Update packages so unit tests work in container
RUN pip install --upgrade pip pyopenssl

EXPOSE 9200
