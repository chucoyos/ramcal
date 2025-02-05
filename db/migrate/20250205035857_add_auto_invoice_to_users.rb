class AddAutoInvoiceToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :auto_invoice, :boolean, default: true
  end
end
