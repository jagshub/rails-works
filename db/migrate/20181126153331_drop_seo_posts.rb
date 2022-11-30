class DropSeoPosts < ActiveRecord::Migration[5.0]
  def change
    drop_table :seo_posts
  end
end
