class CreateContainers < ActiveRecord::Migration[7.2]
  def change
    create_table :containers do |t|
      t.references :user, null: false, foreign_key: true
      t.string :number
      t.integer :size
      t.string :container_type
      t.string :cargo_owner

      t.timestamps
    end
  end
end
