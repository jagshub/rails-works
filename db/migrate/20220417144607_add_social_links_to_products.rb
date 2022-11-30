class AddSocialLinksToProducts < ActiveRecord::Migration[6.1]
  def change
    add_column :products, :twitter_url, :string
    add_column :products, :instagram_url, :string
    add_column :products, :github_url, :string
    add_column :products, :facebook_url, :string
    add_column :products, :medium_url, :string
    add_column :products, :angellist_url, :string
  end
end
