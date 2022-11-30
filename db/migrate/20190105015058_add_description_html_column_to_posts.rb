class AddDescriptionHtmlColumnToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :description_html, :text
  end
end
