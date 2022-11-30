class RemoveNotificationsAboutHiddenPosts < ActiveRecord::Migration
  # Note(andreasklinger): Mocking the model in case future codebases no longer know it
  class MigrationFriendPostNotification < ApplicationRecord
    self.table_name = 'notifications'
  end

  def up
    post_ids = ActiveRecord::Base.connection.execute("select distinct posts.id from notifications, posts where notifications.post_id = posts.id and notifications.type='FriendPostNotification' and posts.hide = 't'").map { |hash| hash["id"] }
    MigrationFriendPostNotification.delete_all(post_id: post_ids, type: 'FriendPostNotification')
  end

  def down
    # noop
  end
end
