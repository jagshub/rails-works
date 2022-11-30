class AddStatusToDiscussionThread < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!
  
  def change
    add_column :discussion_threads, :status, :string, null: true
    add_index :discussion_threads, :status, algorithm: :concurrently
  end
end
