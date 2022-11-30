class ChangeCollectionPostDescriptionToHtmlInput < ActiveRecord::Migration
  def change
    remove_column :collection_post_associations, :description, :text

    add_column :collection_post_associations, :description, :jsonb
  end
end
