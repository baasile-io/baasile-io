def switch_schema(schema)
  Apartment::Tenant.switch! schema.is_a?(Service) ? schema.subdomain : schema
end
