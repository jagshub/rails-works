class AddKindToCollections < ActiveRecord::Migration
  def up
    add_column :collections, :kind, :integer, default: 0, null: false
    # Note(andreasklinger): all collections that exist currently are "official ones"
    execute 'UPDATE collections SET kind = 10'
  end

  def down
    remove_column :collections, :kind
  end
end
