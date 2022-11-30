class CreateRelatedLinks < ActiveRecord::Migration
  def change
    create_table :related_links do |t|
      t.string :url
      t.string :title
      t.references :post, index: true
      t.references :user, index: true

      t.timestamps
    end
  end
end
