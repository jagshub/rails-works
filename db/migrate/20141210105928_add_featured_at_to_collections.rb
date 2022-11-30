class AddFeaturedAtToCollections < ActiveRecord::Migration
  def up
    add_column :collections, :featured_at, :datetime
    add_index :collections, :featured_at

    update_collections = <<-SQL
      update collections
         set featured_at = created_at
       where kind = 10 -- official
    SQL

    execute update_collections
  end

  def down
    remove_column :collections, :featured_at, :datetime
    remove_index :collections, :featured_at
  end
end
