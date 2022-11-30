class ChangeCollectionIntroAndRecapToJsonb < ActiveRecord::Migration
  def change
    remove_column :collections, :intro, :text
    remove_column :collections, :recap, :text

    add_column :collections, :intro, :jsonb
    add_column :collections, :recap, :jsonb
  end
end
