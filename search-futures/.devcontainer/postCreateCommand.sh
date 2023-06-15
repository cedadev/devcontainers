#!/usr/bin/bash

echo "DOCK ENTRYPOINT STARTED as $USER"

if [ "$DATABASE" = "1" ] ; then
    echo "STARTING ELASTICSEARCH"
    /elastic/bin/elasticsearch -d -p /elastic/pid
    stac-fastapi-elasticsearch/scripts/wait-for-it.sh localhost:9200 -t 120
fi

if [ "$DATABASE" = "1" ] && [ "$SERVER" = "1" ] ; then
    echo "INGESTING DATA"
    python stac-fastapi-elasticsearch/scripts/ingest_test_data.py --host localhost:9200
fi

if [ "$SERVER" = "1" ] ; then
    echo "STARTING FASTAPI SERVER"
    cp devcontainers/search-futures/.devcontainer/conf/fastapi_settings.py stac-fastapi-elasticsearch/stac_fastapi/elasticsearch/settings.py
    cd stac-fastapi-elasticsearch
    export STAC_ELASTICSEARCH_SETTINGS=stac_fastapi.elasticsearch.settings
    python -m stac_fastapi.elasticsearch.run
fi
