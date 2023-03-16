FROM mcr.microsoft.com/devcontainers/anaconda:0-3

ARG SERVER=true
# ARG ESGF_VERSION
# ARG PYSTAC_VERSION
# ARG PYSTAC_CLIENT_VERSION
# ARG STAC_FASTAPI_ELASTICSEARCH_VERSION

RUN mkdir -p /workspaces
# Install ESGF-STAC-client
RUN cd /workspaces/ \
    && git clone https://github.com/cedadev/esgf-stac-client \
    && cd esgf-stac-client/ \
    && pip install -r requirements.txt \
    && pip install -r requirements_dev.txt \
    && pip install -e . --no-deps
# Mark repo as safe
RUN git config --system --add safe.directory /workspaces/esgf-stac-client
# Change directory ownership
RUN chown -R vscode:vscode /workspaces/esgf-stac-client

# Install Pystac
RUN cd /workspaces/ \
    && git clone -b asset-search https://github.com/cedadev/pystac \
    && cd pystac/ \
    && pip install -r requirements-dev.txt \
    && pip install -e . --no-deps
# Mark repo as safe
RUN git config --system --add safe.directory /workspaces/pystac
# Change directory ownership
RUN chown -R vscode:vscode /workspaces/pystac

# Install Pystac-client
RUN cd /workspaces/ \
    && git clone -b asset-search https://github.com/cedadev/pystac-client \
    && cd pystac-client/ \
    && perl -p -i -w -e 's/^pystac==1.4.0/#pystac==1.4.0/g' requirements-min.txt \
    && pip install -r requirements-min.txt \
    && pip install -r requirements-dev.txt \
    && pip install -e . --no-deps
# Mark repo as safe
RUN git config --system --add safe.directory /workspaces/pystac-client
# Change directory ownership
RUN chown -R vscode:vscode /workspaces/pystac-client


#Install stac-fastapi-elasticsearch
RUN if [$SERVER="true"] ; then \
RUN    cd /workspaces/ \
    && git clone -b atod https://github.com/cedadev/stac-fastapi-elasticsearch \
    && cd stac-fastapi-elasticsearch/ \
    && pip install -r requirements.txt \
    && pip install django-flexi-settings==0.1.1 \
    && pip install -e .[server,dev] \
    # Mark repo as safe
    && git config --system --add safe.directory /workspaces/stac-fastapi-elasticsearch \
    # Change directory ownership
    && chown -R vscode:vscode /workspaces/stac-fastapi-elasticsearch
# ; fi

RUN if ["true" = "true"]; then echo 'RUNNING TRUE' ; fi

RUN if ["true" = "true"]; then echo 'RUNNING TRUE' ; fi


# # COPY settings.py /workspaces/stac-fastapi-elasticsearch/stac_fastapi/elasticsearch/settings.py

# # Update packages so unit tests work in container
RUN pip install --upgrade pip pyopenssl
