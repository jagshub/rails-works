class CreateProductLinks < ActiveRecord::Migration
  def change
    rename_table :install_links, :product_links

    add_column :product_links, :primary_link, :boolean, default: false, null: false
    add_column :product_links, :clean_url, :text

    change_column :product_links, :post_id, :integer, null: false
    change_column :product_links, :url, :text, null: false
    change_column :product_links, :shortened_link, :text, null: false
    rename_column :product_links, :shortened_link, :short_code

    execute """
    INSERT INTO product_links (post_id, url, short_code, created_at, updated_at, user_id, primary_link, clean_url)
    SELECT p.id, p.url, p.shortened_link, p.created_at, p.updated_at, p.user_id, TRUE, p.url_host
      FROM posts p
    """

    remove_column :posts, :url
    remove_column :posts, :url_host
    remove_column :posts, :shortened_link

    # Make sure we only ever have one primary product link per post
    execute """
    CREATE UNIQUE INDEX ON product_links(post_id) WHERE primary_link
    """
  end
end
