class CorrectlyAddIndexToUserFriendAssoc < ActiveRecord::Migration
  def fetch_ids(sql)
    execute(sql).to_a.map { |result| result['id'] }
  end

  def up
    find_dupes_query = <<-SQL
      select max(id) as id
        from user_friend_associations
       group by (following_user_id, followed_by_user_id)
      having count(*) > 1
    SQL

    find_missing_users_query = <<-SQL
      select uf.id as id
        from user_friend_associations uf
        left join users u ON uf.followed_by_user_id = u.id
       where u.id is null
    SQL

    find_more_missing_users_query = <<-SQL
      select uf.id as id
        from user_friend_associations uf
        left join users u ON uf.following_user_id = u.id
       where u.id is null
    SQL

    ids = fetch_ids(find_dupes_query)
    ids += fetch_ids(find_missing_users_query)
    ids += fetch_ids(find_more_missing_users_query)

    ids.uniq!

    delete_query = <<-SQL
      delete from user_friend_associations
            where id in (#{ ids.join(',') })
    SQL

    execute(delete_query) if ids.any?

    # Avoid wrapping transaction (CONCURRENTLY can't run inside transactions)
    execute 'commit;'

    add_index :user_friend_associations,
              [:followed_by_user_id, :following_user_id],
              algorithm: :concurrently,
              unique: true,
              name: :index_user_friend_assocs_followed_following

    add_foreign_key :user_friend_associations, :users, column: :followed_by_user_id, dependent: :destroy
    add_foreign_key :user_friend_associations, :users, column: :following_user_id, dependent: :destroy

    # Start a new transaction so Rails doesn't get confused
    execute 'begin;'
  end

  def down
    remove_index :user_friend_associations, name: :index_user_friend_assocs_followed_following
    remove_foreign_key :user_friend_associations, column: :followed_by_user_id
    remove_foreign_key :user_friend_associations, column: :following_user_id
  end
end
