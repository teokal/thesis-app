class AddColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :username, :string
    add_column :users, :moodle_token, :string
    add_column :users, :moodle_user_id, :integer
    add_column :users, :expires_at, :date
  end
end
