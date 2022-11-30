class CreateRelatedStoryAssociation < ActiveRecord::Migration[5.1]
  def change
    create_table :anthologies_related_story_associations do |t|
      t.references :story, index: true, foreign_key: { to_table: :anthologies_stories }
      t.references :related, index: true, foreign_key: { to_table: :anthologies_stories }
      t.integer :position, default: 0, null: :false

      t.timestamps
    end

    add_index :anthologies_related_story_associations, [:story_id, :related_id],
      name: 'index_anthologies_related_story_associations_unique',
      unique: true
  end
end
