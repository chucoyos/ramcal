class AddLocationToMoves < ActiveRecord::Migration[7.2]
  def change
    add_reference :moves, :location, foreign_key: true
  end
end
