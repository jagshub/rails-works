class ReaddSubjectIndexForReview < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    return if Rails.env.production?

    remove_index :reviews, %i(subject_type subject_id user_id), algorithm: :concurrently
    add_index :reviews, %i(subject_type subject_id user_id), algorithm: :concurrently
  end

  def down
    return if Rails.env.production?

    remove_index :reviews, %i(subject_type subject_id user_id), algorithm: :concurrently
    add_index :reviews, %i(subject_type subject_id user_id), unique: true, algorithm: :concurrently
  end
end
