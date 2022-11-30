class RevertGinIndexes < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    add_index :users, :username, unique: true, where: 'trashed_at IS NULL', algorithm: :concurrently
  end
end
