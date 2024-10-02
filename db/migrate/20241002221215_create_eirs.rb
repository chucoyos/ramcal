class CreateEirs < ActiveRecord::Migration[7.2]
  def change
    create_table :eirs do |t|
      t.references :container, null: false, foreign_key: true
      t.string :operator
      t.string :transport
      t.string :plate
      t.string :fleet_number

      t.timestamps
    end
  end
end
