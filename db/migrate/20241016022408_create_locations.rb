class CreateLocations < ActiveRecord::Migration[7.2]
  def change
    create_table :locations do |t|
      t.string :section
      t.integer :row
      t.integer :position
      t.integer :tier
      t.boolean :available

      t.timestamps
    end
  end
end
