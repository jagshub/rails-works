class CreateTopicAssociations < ActiveRecord::Migration[5.0]
  def change
    create_table :topic_associations do |t|
      t.belongs_to :topic, null: false, foreign_key: true
      t.belongs_to :subject, null: false, polymorphic: true
      t.timestamps null: false
    end

    add_index :topic_associations, %i(topic_id subject_type subject_id), unique: true, name: 'topic_associations_topic_and_subject_ids'
  end
end
