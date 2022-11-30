class RemoveRelatedLinksTable < ActiveRecord::Migration
  def up
    drop_table :related_links
  end

  def down
    create_table :related_links do |t|
      t.string :url
      t.string :title
      t.string :domain
      t.string :favicon
      t.references :post, index: true
      t.references :user, index: true

      t.timestamps
    end
  end
end
