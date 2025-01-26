class AddPayableAmountToPayables < ActiveRecord::Migration[7.2]
  def change
    add_column :payables, :payment_amount, :decimal, precision: 10, scale: 2, null: false, default: 0.0
  end
end
