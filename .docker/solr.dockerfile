FROM solr:8-slim

COPY ./solr/arclight/conf /solr_config

ENTRYPOINT ["docker-entrypoint.sh", "solr-precreate", "arclight", "/solr_config"]
