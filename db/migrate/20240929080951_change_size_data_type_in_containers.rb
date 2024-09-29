class ChangeSizeDataTypeInContainers < ActiveRecord::Migration[7.2]
  def change
    change_column :containers, :size, :string
  end

  def down
    change_column :containers, :size, :integer
  end
end
