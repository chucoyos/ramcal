class AddCreditLineToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :credit_limit, :decimal, precision: 10, scale: 2, default: 0, null: false
    add_column :users, :available_credit, :decimal, precision: 10, scale: 2, default: 0, null: false
  end
end
