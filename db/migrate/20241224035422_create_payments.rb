class CreatePayments < ActiveRecord::Migration[7.2]
  def change
    create_table :payments do |t|
      t.references :invoice, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2
      t.date :payment_date
      t.string :payment_means

      t.timestamps
    end
  end
end
