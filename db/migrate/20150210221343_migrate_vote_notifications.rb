class MigrateVoteNotifications < ActiveRecord::Migration
  class Activity < ApplicationRecord; end

  def up
    query = "INSERT INTO activities (user_id, subject_id, subject_type, verb, object_id, object_type, seen_at, updated_at, created_at)
      (SELECT n.user_id,
              n.from_user_id AS subject_id,
              'User' AS subject_type,
              'upvoted' AS verb,
              n.post_id AS object_id,
              'Post' AS object_type,
              (SELECT CASE WHEN n.seen=TRUE THEN n.updated_at ELSE NULL END) AS seen_at,
              n.updated_at,
              n.created_at
       FROM notifications n
       WHERE type = 'Notifications::VoteNotification')"

    execute(query)
  end

  def down
    Activity.where(subject_type: 'User', verb: 'upvoted', object_type: 'Post').delete_all
  end
end
