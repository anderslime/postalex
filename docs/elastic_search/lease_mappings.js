{
    "locations": {
        "mappings":
          // CUT HERE WHEN PUT'ING-----------
        {
            "location": {
                "properties": {
                    "_rev": {
                        "type": "string"
                    },
                    "address_line1": {
                        "type": "string"
                    },
                    "area_from": {
                        "type": "double"
                    },
                    "area_to": {
                        "type": "double"
                    },
                    "can_be_ordered": {
                        "type": "boolean"
                    },
                    "created_at": {
                        "type": "date",
                        "format": "dateOptionalTime"
                    },
                    "description": {
                        "type": "string"
                    },
                    "id": {
                        "type": "long"
                    },
                    "kind": {
                        "type": "string"
                    },
                    "location": {
                      "type": "geo_point"
                    },
                    "metadata": {
                        "properties": {
                            "event_date": {
                                "type": "date",
                                "format": "dateOptionalTime"
                            },
                            "event_uuid": {
                                "type": "string"
                            },
                            "seq_number": {
                                "type": "long"
                            },
                            "type": {
                                "type": "string"
                            },
                            "updated_date": {
                                "type": "date",
                                "format": "dateOptionalTime"
                            }
                        }
                    },
                    "postal_code": {
                        "type": "string"
                    },
                    "postal_name": {
                        "type": "string"
                    },
                    "primary_photo": {
                        "type": "string"
                    },
                    "primary_photo_2x": {
                        "type": "string"
                    },
                    "provider_uuid": {
                        "type": "string"
                    },
                    "state": {
                        "type": "string"
                    },
                    "title": {
                        "type": "string"
                    },
                    "uuid": {
                        "type": "string"
                    },
                    "yearly_rent_per_m2_amount_from": {
                        "type": "long"
                    },
                    "yearly_rent_per_m2_amount_to": {
                        "type": "long"
                    }
                }
            }
        }
    }
}
