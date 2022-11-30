class MigrateMentionNotifications < ActiveRecord::Migration
  class Activity < ApplicationRecord; end

  def up
    query = "INSERT INTO activities (user_id, subject_id, subject_type, verb, object_id, object_type, seen_at, updated_at, created_at)
      (SELECT n.user_id,
              n.from_user_id AS subject_id,
              'User' AS subject_type,
              'mentioned_user_in' AS verb,
              n.comment_id AS object_id,
              'Comment' AS object_type,
              (SELECT CASE WHEN n.seen=TRUE THEN n.updated_at ELSE NULL END) AS seen_at,
              n.updated_at,
              n.created_at
       FROM notifications n
       WHERE type = 'Notifications::MentionNotification')"

    execute(query)
  end

  def down
    Activity.where(subject_type: 'User', verb: 'mentioned_user_in', object_type: 'Comment').delete_all
  end
end
