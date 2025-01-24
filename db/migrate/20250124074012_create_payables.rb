class CreatePayables < ActiveRecord::Migration[7.2]
  def change
    create_table :payables do |t|
      t.date :payment_date
      t.string :payment_type
      t.string :payment_means
      t.string :payment_concept
      t.references :supplier, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
