class AddRoleReasonToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :role_reason, :integer, null: true
  end
end
