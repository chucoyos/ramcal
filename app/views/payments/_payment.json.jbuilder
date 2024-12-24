json.extract! payment, :id, :Invoice_id, :amount, :payment_date, :payment_means, :created_at, :updated_at
json.url payment_url(payment, format: :json)
