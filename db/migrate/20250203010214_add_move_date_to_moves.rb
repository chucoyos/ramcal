class AddMoveDateToMoves < ActiveRecord::Migration[8.0]
  def change
    add_column :moves, :move_date, :datetime
  end
end
