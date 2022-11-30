class FixNamespaceForNotifications < ActiveRecord::Migration
  class MigrationNotification < ApplicationRecord
    self.table_name = 'notifications'
  end

  def up
    MigrationNotification.where(type: 'CommentNotification').update_all(type: 'Notifications::CommentNotification')
    MigrationNotification.where(type: 'VoteNotification').update_all(type: 'Notifications::VoteNotification')
    MigrationNotification.where(type: 'MentionNotification').update_all(type: 'Notifications::MentionNotification')
    MigrationNotification.where(type: 'ReplyNotification').update_all(type: 'Notifications::ReplyNotification')
    MigrationNotification.where(type: 'FriendPostNotification').update_all(type: 'Notifications::FriendPostNotification')
  end

  def down
    MigrationNotification.where(type: 'Notifications::CommentNotification').update_all(type: 'CommentNotification')
    MigrationNotification.where(type: 'Notifications::VoteNotification').update_all(type: 'VoteNotification')
    MigrationNotification.where(type: 'Notifications::MentionNotification').update_all(type: 'MentionNotification')
    MigrationNotification.where(type: 'Notifications::ReplyNotification').update_all(type: 'ReplyNotification')
    MigrationNotification.where(type: 'Notifications::FriendPostNotification').update_all(type: 'FriendPostNotification')
  end
end
