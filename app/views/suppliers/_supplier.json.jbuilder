json.extract! supplier, :id, :name, :contact, :phone, :email, :created_at, :updated_at
json.url supplier_url(supplier, format: :json)
