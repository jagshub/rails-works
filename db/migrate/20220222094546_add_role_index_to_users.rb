class AddRoleIndexToUsers < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index(:users, :role, algorithm: :concurrently)
  end
end
