class AddSealToMoves < ActiveRecord::Migration[7.2]
  def change
    add_column :moves, :seal, :string
  end
end
