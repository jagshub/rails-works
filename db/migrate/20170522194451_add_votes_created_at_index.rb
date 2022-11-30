class AddVotesCreatedAtIndex < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_index :votes, :created_at, algorithm: :concurrently
  end
end
