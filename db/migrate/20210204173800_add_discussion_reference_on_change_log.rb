class AddDiscussionReferenceOnChangeLog < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    safety_assured do
      rename_column :change_log_entries, :create_discussion, :has_discussion
    end

    add_reference :change_log_entries, :discussion_thread, foreign_key: :true, index: false
    add_index :change_log_entries, :discussion_thread_id, algorithm: :concurrently
  end
end
