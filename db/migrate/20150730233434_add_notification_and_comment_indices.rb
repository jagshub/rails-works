class AddNotificationAndCommentIndices < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_index :notifications, [:notifyable_id, :notifyable_type], algorithm: :concurrently
    add_index :comments, [:subject_id, :subject_type], algorithm: :concurrently
  end
end
