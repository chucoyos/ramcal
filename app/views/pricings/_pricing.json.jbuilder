json.extract! pricing, :id, :client_id, :service_id, :price, :grace_period_days, :created_at, :updated_at
json.url pricing_url(pricing, format: :json)
