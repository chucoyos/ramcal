class CreateNotifications < ActiveRecord::Migration[7.2]
  def change
    create_table :notifications do |t|
      t.text :message
      t.boolean :completed
      t.references :move, null: false, foreign_key: true

      t.timestamps
    end
  end
end
