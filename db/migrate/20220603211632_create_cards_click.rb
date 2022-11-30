class CreateCardsClick < ActiveRecord::Migration[6.1]
  def change
    create_table :cards_clicks do |t|
      t.references :subject, polymorphic: true, index: true
      t.string :referrer_url, null: false
      t.string :track_code, null: true
      t.integer :user_id, null: true
      t.string :ip_address, null: false
      t.string :user_agent, null: true

      t.timestamps
    end
  end
end
