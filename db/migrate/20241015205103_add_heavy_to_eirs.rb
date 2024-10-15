class AddHeavyToEirs < ActiveRecord::Migration[7.2]
  def change
    add_column :eirs, :heavy, :string
  end
end
