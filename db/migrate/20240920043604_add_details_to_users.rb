class AddDetailsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :username, :string
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :second_last_name, :string
    add_column :users, :contact_person, :string
    add_column :users, :phone_number, :string
    add_column :users, :user_type, :int
  end
end
