#Postalex

GenServer exposing services related to postal areas


## Include as dependency
_Via github_

`{:postalex, github: "ringling/postalex"}`

_or locally via path_


`git clone https://github.com/ringling/couchex`
`{:postalex, path: "../postalex"}`

## Setup

The following environment variables are required
```
COUCH_SERVER_URL=<COUCH_SERVER_URL> #E.g https://couch.lokalebasen.dk
COUCH_USER=<USERNAME>
COUCH_PASS=<PASSWORD>
```

## CouchDB

CouchDB databases __must__ have the format *{country}\_{table_name}* or *{country}\_{category}\_{table_name}*, depending on whether their content is category(sales, lease etc) specific. Examples


* dk_postal_areas
* se_postal_areas
* dk_lease_locations
* dk_sales_locations
* se_lease_locations # PENDING
* se_sales_locations # PENDING

### CouchDB views


```json
// Danish area => from dk_postal_areas database
{
	"_id": "bornholm",
	"_rev": "...",
	"type": "area",
	"id": "bornholm",
	"name": "Bornholm",
	"postal_districts": [
		{
			"type": "postal_district",
			"name": "Svaneke",
			"id": "3740-svaneke",
			"postal_codes": [
			   {
			       "postal_name": "Svaneke",
			       "postal_code": "3740",
			       "type": "postal_code"
			   }
			   ...
			]
		},
	...

```

```json
// Swedish area => from se_postal_areas database
{
	"_id": "dalarna",
	"_rev": "...",
	"type": "area",
	"id": "dalarna",
	"name": "Dalarna",
	"postal_districts": [
		{
			"type": "postal_district",
			"name": "Malung-Sälen",
			"id": "malung-salen",
			"postal_codes": [
			  {
					"postal_name": "Hagfors",
					"postal_code": "68391",
					"type": "postal_code"
				}
				...
			]
		},
```

#### Required views

```json
// {country}_postal_areas databases
{
   "_id": "_design/lists",
   "_rev": "7-684689ddbf6370bee370bb18c0382f59",
   "language": "javascript",
   "views": {
       "all": {
           "map": "function(doc) {\n  emit(doc.id, doc);\n}"
       },
       "postal_codes": {
           "map": "function(doc) {\n  pds = doc.postal_districts\n  for(i=0;i<pds.length;i++){\n    pcs = pds[i].postal_codes\n    for(j=0;j<pcs.length;j++){\n      data = { postal_name: pcs[j].postal_name, postal_code: pcs[j].postal_code, type: pcs[j].type, postal_district_id: pds[i].id}\n      emit(pcs[j].postal_code, data );\n    }\n  }\n}"
       },
       "postal_districts": {
           "map": "function(doc) {\n  pds = doc.postal_districts\n  for(i=0;i<pds.length;i++){\n    pd = pds[i]\n    emit(pd.id, {id: pd.id, name: pd.name, slug: pd.slug, key: pd.key } );\n  }\n}"
       }
   }
}
```

