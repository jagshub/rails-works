class RefreshCounterCaches < ActiveRecord::Migration
  def up
    # Avoid wrapping transaction (locking issues!)
    execute 'commit;'

    # Avoid spilling the log with SQL statements
    ActiveRecord::Base.logger.level = Logger::INFO

    puts format('Refreshing %d counter caches', User.count)
    User.find_each do |u|
      u.refresh_follower_count
      u.refresh_friend_count
      print '.'
    end

    # Start a new transaction so Rails doesn't get confused
    execute 'begin;'
  end

  def down
  end
end
