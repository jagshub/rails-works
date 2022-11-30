class AddSlugToDiscussionThread < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    add_column :discussion_threads, :slug, :string
    add_index :discussion_threads, :slug, unique: true, algorithm: :concurrently
  end
end
