// NOT WORKING AS WE HAVE NO LEASE DATA YET
{
  "location": {
    "properties": {
      "_links": {
        "properties": {
          "self": {
            "properties": {
              "href": {
                "type": "string"
              }
            }
          }
        }
      },
      "address_line_1": {
        "type": "string"
      },
      "area_ids": {
        "type": "string"
      },
      "category": {
        "type": "string"
      },
      "created_at": {
        "type": "date",
        "format": "dateOptionalTime"
      },
      "floor_area": {
        "type": "long"
      },
      "id": {
        "type": "long"
      },
      "kind": {
        "type": "string"
      },
      "latitude": {
        "type": "double"
      },
      "location": {
        "type": "geo_point"
      },
      "longitude": {
        "type": "double"
      },
      "photos": {
        "properties": {
          "info_window_image_url": {
            "type": "string"
          },
          "list_image_url": {
            "type": "string"
          }
        }
      },
      "postal_code": {
        "type": "string"
      },
      "postal_district_id": {
        "type": "string"
      },
      "postal_name": {
        "type": "string"
      },
      "price": {
        "type": "long"
      },
      "state": {
        "type": "string"
      },
      "uuid": {
        "type": "string"
      }
    }
  }
}
