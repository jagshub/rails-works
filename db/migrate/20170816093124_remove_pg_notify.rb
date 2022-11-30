class RemovePgNotify < ActiveRecord::Migration
  def change
    execute 'DROP TRIGGER collection_subscriptions_change_trigger ON collection_subscriptions;'
    execute 'DROP TRIGGER collections_change_trigger ON collections;'
    execute 'DROP TRIGGER post_topic_associations_change_trigger ON post_topic_associations;'
    execute 'DROP TRIGGER posts_change_trigger ON posts;'
    execute 'DROP TRIGGER comments_change_trigger ON comments;'
    execute 'DROP TRIGGER product_makers_change_trigger ON product_makers;'
    execute 'DROP TRIGGER collection_post_associations_change_trigger ON collection_post_associations;'
    execute 'DROP TRIGGER topics_change_trigger ON topics;'
    execute 'DROP TRIGGER related_post_associations_change_trigger ON related_post_associations;'
    execute 'DROP TRIGGER topic_user_associations_change_trigger ON topic_user_associations;'
    execute 'DROP TRIGGER votes_change_trigger ON votes;'
    execute 'DROP TRIGGER user_friend_associations_change_trigger ON user_friend_associations;'
    execute 'DROP TRIGGER ama_event_subscriptions_change_trigger ON ama_event_subscriptions;'
    execute 'DROP FUNCTION change_trigger_v2();'
    execute 'DROP FUNCTION json_object_set_key(json json, key_to_set text, value_to_set anyelement);'
  end
end
