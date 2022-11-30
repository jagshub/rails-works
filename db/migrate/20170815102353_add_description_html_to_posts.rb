class AddDescriptionHtmlToPosts < ActiveRecord::Migration
  def change
    remove_column :posts, :description, :string
    add_column :posts, :description, :jsonb
  end
end
