class RemoveNotificationsForHiddenPosts < ActiveRecord::Migration
  def up
    delete_query = <<-SQL
      delete from notifications
            where post_id in ( select post_id
                                 from notifications, posts
                                where posts.id = notifications.post_id
                                  and posts.hide = 't' )
    SQL

    execute(delete_query)
  end

  def down
    # noop
  end
end
