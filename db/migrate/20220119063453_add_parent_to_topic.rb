class AddParentToTopic < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_reference :topics, :parent, index: false, null: true
    add_index :topics, :parent_id, algorithm: :concurrently
  end
end
