class CreateCollectionTopicAssociation < ActiveRecord::Migration
  def change
    create_table :collection_topic_associations do |t|
      t.integer :collection_id, null: false
      t.integer :topic_id, null: false
      t.timestamps null: false
    end

    add_foreign_key :collection_topic_associations, :collections
    add_foreign_key :collection_topic_associations, :topics

    add_index :collection_topic_associations, [:collection_id, :topic_id], unique: true, name: 'collection_topic_associations_collection_topic'
  end
end
