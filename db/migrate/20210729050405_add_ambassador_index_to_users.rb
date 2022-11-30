class AddAmbassadorIndexToUsers < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :users, :ambassador, algorithm: :concurrently
  end
end
