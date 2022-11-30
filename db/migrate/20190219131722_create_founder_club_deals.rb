class CreateFounderClubDeals < ActiveRecord::Migration[5.0]
  def change
    create_table :founder_club_deals do |t|
      t.string :title, null: false
      t.string :logo_uuid
      t.string :value, null: false
      t.string :summary, null: false
      t.string :partner_website, null: false
      t.text :details, null: false
      t.text :terms, null: false
      t.text :how_to_claim, null: false
      t.boolean :active, default: true, null: false
      t.datetime :trashed_at
      t.integer :priority, default: 0, null: false
      t.string :badges, array: true, default: [], null: false
      t.timestamps
    end

    add_index :founder_club_deals, %i(active trashed_at), where: 'active = true and trashed_at is null'
  end
end
