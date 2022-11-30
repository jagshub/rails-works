class AddPublishedAtToPosts < ActiveRecord::Migration
  def up
    add_column :posts, :published_at, :datetime

    init_published_at_values_sql = <<-SQL
      update posts
         set published_at = created_at
    SQL

    execute init_published_at_values_sql
  end

  def down
    remove_column :posts, :published_at
  end
end
