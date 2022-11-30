class RemoveUnneededIndexesFromPost < ActiveRecord::Migration
  def up
    remove_index :posts, name: :index_posts_on_created_at
    remove_index :posts, name: :index_posts_on_published_at
    remove_index :posts, name: :index_posts_on_user_id
  end

  def down
    add_index "posts", ["user_id"], name: "index_posts_on_user_id", using: :btree
    add_index "posts", ["created_at"], name: "index_posts_on_created_at", where: "(NOT hide)", using: :btree
    add_index "posts", ["published_at"], name: "index_posts_on_published_at", where: "(NOT hide)", using: :btree
  end
end
