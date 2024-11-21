class CreateServices < ActiveRecord::Migration[7.2]
  def change
    create_table :services do |t|
      t.references :container, null: true, foreign_key: true
      t.string :name
      t.decimal :charge, precision: 10, scale: 2
      t.boolean :invoiced
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
