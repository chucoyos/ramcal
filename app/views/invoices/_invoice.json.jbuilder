json.extract! invoice, :id, :user_id, :total, :status, :issue_date, :due_date, :created_at, :updated_at
json.url invoice_url(invoice, format: :json)
