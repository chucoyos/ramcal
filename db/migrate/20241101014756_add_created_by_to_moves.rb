class AddCreatedByToMoves < ActiveRecord::Migration[7.2]
  def change
    add_column :moves, :created_by_id, :integer
  end
end
