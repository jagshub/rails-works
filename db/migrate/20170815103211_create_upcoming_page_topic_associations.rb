class CreateUpcomingPageTopicAssociations < ActiveRecord::Migration
  def change
    create_table :upcoming_page_topic_associations do |t|
      t.integer :upcoming_page_id, null: false
      t.integer :topic_id, null: false
      t.timestamps null: false
    end

    add_foreign_key :upcoming_page_topic_associations, :upcoming_pages
    add_foreign_key :upcoming_page_topic_associations, :topics

    add_index :upcoming_page_topic_associations, [:upcoming_page_id, :topic_id], unique: true, name: 'upcoming_page_topic_associations_upcoming_page_topic'
  end
end
