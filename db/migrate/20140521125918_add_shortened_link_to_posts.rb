class AddShortenedLinkToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :shortened_link, :string
  end
end
