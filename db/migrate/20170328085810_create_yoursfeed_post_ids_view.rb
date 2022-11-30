class CreateYoursfeedPostIdsView < ActiveRecord::Migration
  def change
    reversible do |d|
      d.up do
        execute %(
        CREATE MATERIALIZED VIEW yours_feed_post_ids AS (
          SELECT post_id, created_at AS sort_date, 'Collection' AS relation_type, collection_id AS relation_id FROM collection_post_associations WHERE created_at IS NOT NULL AND created_at > now() - interval '3 months'
          UNION
          SELECT post_id, posts.featured_at AS sort_date, 'Topic' AS relation_type, topic_id AS relation_id FROM post_topic_associations
          INNER JOIN posts ON posts.id = post_topic_associations.post_id
          AND posts.featured_at IS NOT NULL AND featured_at > now() - interval '3 months' AND featured_at < now()
        ))
        execute 'REFRESH MATERIALIZED VIEW yours_feed_post_ids'
      end
      d.down do
        execute 'DROP MATERIALIZED VIEW yours_feed_post_ids'
      end
    end

    add_index :yours_feed_post_ids, %i(post_id relation_type relation_id), unique: true, name: :yours_feed_post_ids_unique_key
    add_index :yours_feed_post_ids, %i(relation_type relation_id), name: :yours_feed_post_ids_relation
  end
end
