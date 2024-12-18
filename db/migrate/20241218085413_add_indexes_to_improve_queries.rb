class AddIndexesToImproveQueries < ActiveRecord::Migration[7.2]
  def change
    add_index :moves, :move_type
    add_index :containers, :created_at
  end
end
