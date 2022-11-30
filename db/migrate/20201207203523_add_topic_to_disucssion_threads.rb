class AddTopicToDisucssionThreads < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    add_column :discussion_threads, :topic, :string, null: true
    add_index :discussion_threads, :topic, algorithm: :concurrently
  end
end
