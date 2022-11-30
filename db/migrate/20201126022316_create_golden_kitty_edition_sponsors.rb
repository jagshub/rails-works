class CreateGoldenKittyEditionSponsors < ActiveRecord::Migration[5.1]
  def change
    create_table :golden_kitty_edition_sponsors do |t|
      t.references :edition, foreign_key: { to_table: :golden_kitty_editions }, null: false
      t.references :sponsor, foreign_key: { to_table: :golden_kitty_sponsors }, null: false

      t.timestamps
    end

    add_index :golden_kitty_edition_sponsors, [:edition_id, :sponsor_id], unique: true, name: 'index_gk_edition_sponsors_on_edition_id_and_sponsor_id'
  end
end
