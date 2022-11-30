class CreateSeoQueries < ActiveRecord::Migration[5.0]
  def change
    create_table :seo_queries do |t|
      t.references :subject, null: false, polymorphic: true, index: true
      t.string :query, null: false
      t.float :ctr, default: 0
      t.float :position, default: 0
      t.integer :clicks, default: 0
      t.integer :impressions, default: 0
      t.timestamps null: false
    end
  end
end
