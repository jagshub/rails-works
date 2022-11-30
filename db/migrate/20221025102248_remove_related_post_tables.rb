class RemoveRelatedPostTables < ActiveRecord::Migration[6.1]
  def change
    # Note(AR): Data backup in dropbox: 2. Development > Data Archive
    drop_table :related_post_associations, force: :cascade
    drop_table :related_post_suggestions, force: :cascade
  end
end
