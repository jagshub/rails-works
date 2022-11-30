class AddIntroAndRecapHtmlToCollections < ActiveRecord::Migration[5.0]
  def change
    add_column :collections, :intro_html, :text
    add_column :collections, :recap_html, :text
  end
end
