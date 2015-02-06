# Elasticsearch

## Create - Lease location mapping

See docs/elastic_search/sales_mappings.js

See docs/elastic_search/lease_mappings.js

## Create - river mapping

Create river, syncing from CouchDB to ElasticSearch

__https is quirky__ Chef needs to tell the ES Java configuration, about intermediate certificate


```
# Create river
curl -X PUT 'https://elastic01.lokalebasen.dk/_river/locations/_meta' -d '{\n  "type" : "couchdb",\n  "couchdb" : { "host" : "sofa.lokalebasen.dk", "port" : 5984, "user" : "<COUCH_USER>", "password" : "<COUCH_PASS>", "db" : "dk_locations", "filter" : null },\n  "index" : { "index" : "dk_locations", "type" : "location", "bulk_size" : "100", "bulk_timeout" : "10ms" }\n}'
```

## Indeces

### 1-to-1 with CouchDB databases

* dk_postal_areas/areas
* se_postal_areas

* dk_lease_locations
* dk_sales_locations
* se_lease_locations
* se_sales_locations # NOT in Sweden yet
