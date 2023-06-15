# encoding: utf-8
"""

"""
__author__ = "Rhys Evans"
__date__ = "24 Jan 2023"
__copyright__ = "Copyright 2018 United Kingdom Research and Innovation"
__license__ = "BSD - see LICENSE file in top-level package directory"
__contact__ = "rhys.r.evans@stfc.ac.uk"

import os

ELASTICSEARCH_CONNECTION = {
    "hosts": ["locahost:9200"],
    "verify_certs": False,
    "ssl_show_warn": False,
}

COLLECTION_INDEX = "stac-collections"
ITEM_INDEX = "stac-items"
ASSET_INDEX = "stac-assets"

STAC_DESCRIPTION = "CEDA STAC API"
STAC_TITLE = "CEDA STAC API"

APP_HOST = os.environ.get("APP_HOST", "0.0.0.0")
APP_PORT = int(os.environ.get("APP_PORT", 8080))

enable_response_models = True
openapi_url = "/api"
docs_url = "/docs"

posix_download_url = "https://data.ceda.ac.uk"
