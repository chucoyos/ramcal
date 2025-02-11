class AddCapacityToLocations < ActiveRecord::Migration[8.0]
  def change
    add_column :locations, :capacity, :integer, default: 40
  end
end
