class AddIntroAndRecapToCollections < ActiveRecord::Migration
  def change
    add_column :collections, :intro, :text, null: true
    add_column :collections, :recap, :text, null: true
  end
end
