class AddDescriptionHtmlToCollectionPostAssociation < ActiveRecord::Migration[5.0]
  def change
    add_column :collection_post_associations, :description_html, :text
  end
end
