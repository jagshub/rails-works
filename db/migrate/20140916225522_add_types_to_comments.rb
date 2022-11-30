class AddTypesToComments < ActiveRecord::Migration
  class MigrationNotification < ApplicationRecord
    self.table_name = 'notifications'
  end

  def change
    MigrationNotification.where(body: 'commented on').update_all(type: 'CommentNotification')
    MigrationNotification.where(body: 'mentioned you in').update_all(type: 'MentionNotification')
    MigrationNotification.where(body: 'upvoted').update_all(type: 'VoteNotification')

    change_column :notifications, :type, :string, null: false
  end
end
