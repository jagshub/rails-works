class FixCommentSubjectIndex < ActiveRecord::Migration[5.0]
  disable_ddl_transaction!

  def up
    add_index :comments, [:subject_type, :subject_id, :user_id, :parent_comment_id], algorithm: :concurrently, name: 'index_comments_on_subject_and_user_and_parent'
    execute 'DROP INDEX CONCURRENTLY index_comments_on_subject_id_and_subject_type'
  end

  def down
    add_index :comments, [:subject_id, :subject_type], algorithm: :concurrently
    execute 'DROP INDEX CONCURRENTLY index_comments_on_subject_and_user_and_parent'
  end
end
