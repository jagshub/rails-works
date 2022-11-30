class AddPostIdToMedia < ActiveRecord::Migration
  def change
    reversible {|d| d.up { execute 'commit;' } }

    add_column :product_media, :post_id, :integer

    add_index :product_media, :post_id, algorithm: :concurrently

    add_column :posts, :header_media_id, :integer
    add_column :posts, :thumbnail_media_id, :integer
    add_column :posts, :social_image_media_id, :integer

    reversible {|d| d.up { execute 'commit;' } }
  end
end
