class AddFieldsToRelatedLinks < ActiveRecord::Migration
  def change
    add_column :related_links, :domain, :string
    add_column :related_links, :favicon, :string
  end
end
