class AddLastProductAddedAtToCollections < ActiveRecord::Migration
  def change
    add_column :collections, :last_post_added_at, :datetime
  end
end
