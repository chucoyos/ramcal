class CreateMoves < ActiveRecord::Migration[7.2]
  def change
    create_table :moves do |t|
      t.references :container, null: false, foreign_key: true
      t.string :move_type
      t.string :status
      t.string :mode
      t.text :notes
      t.string :images

      t.timestamps
    end
  end
end
