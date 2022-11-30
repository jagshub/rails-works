class AddStoryAssociationToNewsletters < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_reference :newsletters, :anthologies_story, null: true, index: false
    add_index :newsletters, :anthologies_story_id, algorithm: :concurrently
  end
end
