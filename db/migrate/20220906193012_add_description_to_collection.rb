class AddDescriptionToCollection < ActiveRecord::Migration[6.1]
  def change
    add_column :collections, :description, :text
  end
end