class CreateAdsInteractions < ActiveRecord::Migration[5.1]
  def change
    create_table :ads_interactions do |t|
      t.references :placement,
                   foreign_key: { to_table: :ads_placements },
                   null: false

      t.references :user, foreign_key: false, index: false, null: true
      t.string :track_code, null: false
      t.string :kind, null: false
      t.string :reference
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end
  end
end
