class RemigrateNotificationsToActivities < ActiveRecord::Migration
  class Activity < ApplicationRecord; end

  def up
    execute('TRUNCATE TABLE activities');

    # Migrate 'User commented on post' notifications
    execute("INSERT INTO activities (id, user_id, subject_id, subject_type, verb, object_id, object_type, target_id, target_type, seen_at, updated_at, created_at)
        (SELECT n.id,
                n.user_id,
                n.from_user_id AS subject_id,
                'User' AS subject_type,
                'created' AS verb,
                n.comment_id AS object_id,
                'Comment' AS object_type,
                n.post_id AS target_id,
                'Post' AS target_type,
                (SELECT CASE WHEN n.seen=TRUE THEN n.updated_at ELSE NULL END) AS seen_at,
                n.updated_at,
                n.created_at
         FROM notifications n
         WHERE type = 'Notifications::CommentNotification')")

    # Migrate 'User upvoted post' notifications
    execute("INSERT INTO activities (id, user_id, subject_id, subject_type, verb, object_id, object_type, seen_at, updated_at, created_at)
      (SELECT n.id,
              n.user_id,
              n.from_user_id AS subject_id,
              'User' AS subject_type,
              'upvoted' AS verb,
              n.post_id AS object_id,
              'Post' AS object_type,
              (SELECT CASE WHEN n.seen=TRUE THEN n.updated_at ELSE NULL END) AS seen_at,
              n.updated_at,
              n.created_at
       FROM notifications n
       WHERE type = 'Notifications::VoteNotification')")

    # Migrate 'User created post' notifications
    execute("INSERT INTO activities (id, user_id, subject_id, subject_type, verb, object_id, object_type, seen_at, updated_at, created_at)
      (SELECT n.id,
              n.user_id,
              n.from_user_id AS subject_id,
              'User' AS subject_type,
              'created' AS verb,
              n.post_id AS object_id,
              'Post' AS object_type,
              (SELECT CASE WHEN n.seen=TRUE THEN n.updated_at ELSE NULL END) AS seen_at,
              n.updated_at,
              n.created_at
       FROM notifications n
       WHERE type = 'Notifications::FriendPostNotification')")

    # Migrate 'User mentioned user in comment' notifications
    execute("INSERT INTO activities (id, user_id, subject_id, subject_type, verb, object_id, object_type, target_id, target_type, seen_at, updated_at, created_at)
      (SELECT n.id,
              n.user_id,
              n.from_user_id AS subject_id,
              'User' AS subject_type,
              'mentioned' AS verb,
              n.user_id AS object_id,
              'User' AS object_type,
              n.comment_id AS target_id,
              'Comment' AS target_type,
              (SELECT CASE WHEN n.seen=TRUE THEN n.updated_at ELSE NULL END) AS seen_at,
              n.updated_at,
              created_at
       FROM notifications n
       WHERE type = 'Notifications::MentionNotification')")

    # Migrate 'User replied to a comment' notifications
    execute("INSERT INTO activities (id, user_id, subject_id, subject_type, verb, object_id, object_type, target_id, target_type, seen_at, updated_at, created_at)
      (SELECT n.id,
              n.user_id,
              n.from_user_id AS subject_id,
              'User' AS subject_type,
              'created' AS verb,
              c.id AS object_id,
              'Comment' AS object_type,
              c.parent_comment_id AS target_id,
              'Comment' AS target_type,
              (SELECT CASE WHEN n.seen=TRUE THEN n.updated_at ELSE NULL END) AS seen_at,
              n.updated_at,
              n.created_at
       FROM notifications n
       INNER JOIN comments c ON n.comment_id = c.id
       WHERE type = 'Notifications::ReplyNotification')")
  end

  def down; end
end
