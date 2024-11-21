json.extract! pricing, :id, :client_id, :service_id, :price, :grace_period_days, :start_delay, :created_at, :updated_at
json.url pricing_url(pricing, format: :json)
