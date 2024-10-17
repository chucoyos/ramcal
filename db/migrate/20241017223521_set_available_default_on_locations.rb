class SetAvailableDefaultOnLocations < ActiveRecord::Migration[7.2]
  def change
    change_column_default :locations, :available, from: nil, to: true
  end
end
