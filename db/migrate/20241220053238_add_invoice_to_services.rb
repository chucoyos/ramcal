class AddInvoiceToServices < ActiveRecord::Migration[7.2]
  def change
    add_reference :services, :invoice, foreign_key: true
  end
end
