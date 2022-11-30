class AddAttributesToMakerFestivalEdition < ActiveRecord::Migration[5.1]
  def change
    add_column :makers_festival_editions, :slug, :string, null: true
    add_column :makers_festival_editions, :name, :string, null: true
    add_column :makers_festival_editions, :tagline, :string, null: true
    add_column :makers_festival_editions, :description, :text, null: true
    add_column :makers_festival_editions, :prizes, :text, null: true
    add_column :makers_festival_editions, :discussion_preview_uuid, :string, null: true
    add_column :makers_festival_editions, :embed_url, :string, null: true

    change_column_null :makers_festival_editions, :sponsor, true

    add_index :makers_festival_editions, :slug, unique: true
  end
end
