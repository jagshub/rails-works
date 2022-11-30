class CreateDiscussionThreads < ActiveRecord::Migration[5.0]
  def change
    create_table :discussion_threads do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.integer :comments_count, null: false, default: 0
      t.datetime :trashed_at
      t.references :subject, polymorphic: true, null: false, index: true
      t.references :user, foreign_key: true, null: false, index: true
      t.boolean :anonymous, null: false, default: false
      t.boolean :pinned, null: false, default: false

      t.timestamps
    end

    add_index :discussion_threads, :trashed_at, where: "(trashed_at IS NOT NULL)"
    add_index :discussion_threads, %i(user_id subject_id subject_type), name: 'index_discussion_thread_on_user_subject'
  end
end
