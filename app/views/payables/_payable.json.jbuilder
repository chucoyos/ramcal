json.extract! payable, :id, :payment_date, :payment_type, :payment_means, :payment_concept, :supplier_id, :user_id, :created_at, :updated_at
json.url payable_url(payable, format: :json)
