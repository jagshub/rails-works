class RemoveTopicFollowTriggers < ActiveRecord::Migration
  def up
    execute 'DROP TRIGGER IF EXISTS legacy_topic_follow_sync_trigger ON topic_user_associations;'
    execute 'DROP FUNCTION IF EXISTS legacy_topic_follow_sync();'
  end
end
