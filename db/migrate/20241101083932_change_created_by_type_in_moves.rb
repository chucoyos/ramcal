class ChangeCreatedByTypeInMoves < ActiveRecord::Migration[7.2]
  def change
    change_column :moves, :created_by_id, :bigint
  end
end
