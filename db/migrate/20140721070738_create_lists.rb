class CreateLists < ActiveRecord::Migration
  def change
    create_table :lists do |t|
      t.references  :user, null: false
      t.string      :slug, null: false
      t.string      :name, null: false
      t.string      :title
      t.string      :image_url
      t.boolean     :promoted, default: false, null: false
    end
    add_index :lists, [:slug]

    create_table :list_post_associations do |t|
      t.references :list, :post
    end
    add_index :list_post_associations, [:list_id, :post_id]
  end
end
