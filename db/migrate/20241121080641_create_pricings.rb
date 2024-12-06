class CreatePricings < ActiveRecord::Migration[7.2]
  def change
    create_table :pricings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :service, null: false, foreign_key: true
      t.decimal :price, precision: 10, scale: 2
      t.integer :grace_period_days

      t.timestamps
    end
  end
end
