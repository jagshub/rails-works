class AddIndices < ActiveRecord::Migration
  def change
    # Avoid wrapping transaction (CONCURRENTLY can't run inside transactions)
    reversible {|d| d.up { execute 'commit;' } }

    add_index :posts, :created_at, where: "NOT hide", algorithm: :concurrently
    add_index :posts, :shortened_link, algorithm: :concurrently
    add_index :link_trackers, :track_code, algorithm: :concurrently, algorithm: :concurrently
    add_index :link_trackers, :post_id, algorithm: :concurrently
    add_index :comments, :parent_comment_id, algorithm: :concurrently

    reversible do |d|
      d.up do
        execute 'CREATE INDEX CONCURRENTLY index_users_on_username ON users(lower(username))'
      end
      d.down do
        remove_index :users, :username
      end
    end

    # Start a new transaction so Rails doesn't get confused
    reversible {|d| d.up { execute 'begin;' } }
  end
end
