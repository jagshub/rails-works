class AddCategoriesAndMentionedProductsToStories < ActiveRecord::Migration[5.1]
  def change
    create_table :anthologies_story_mentions_associations do |t|
      t.references :story, null: false, index: false, foreign_key: { to_table: :anthologies_stories }
      t.references :subject, polymorphic: true, index: false, null: false
      t.timestamps null: false
    end

    add_index :anthologies_story_mentions_associations, [:subject_type, :subject_id], name: "index_mentions_on_subject_id_and_subject_type"
    add_index :anthologies_story_mentions_associations, [:story_id, :subject_id, :subject_type], unique: true, name: "index_mentions_on_story_id_and_subject_id_and_subject_type"

    add_column :anthologies_stories, :category, :string, null: true, index: true
  end
end
