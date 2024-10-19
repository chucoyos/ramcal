class ModifyLocations < ActiveRecord::Migration[7.2]
  def change
    remove_column :locations, :row, :integer
    remove_column :locations, :position, :integer
    remove_column :locations, :tier, :integer

    rename_column :locations, :section, :location
  end
end
