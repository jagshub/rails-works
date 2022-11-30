class CreateGoldenKittyEditions < ActiveRecord::Migration[5.1]
  def change
    safety_assured do
      create_table :golden_kitty_editions do |t|
        t.integer :year, null: false
        t.string :social_image, null: true
        t.string :social_share_text, null: true
        t.datetime :nomination_starts_at, null: false
        t.datetime :nomination_ends_at, null: false
        t.datetime :voting_starts_at, null: false
        t.datetime :voting_ends_at, null: false
        t.datetime :result_at, null: false

        t.timestamps
      end

      add_reference :golden_kitty_categories, :edition, foreign_key: { to_table: :golden_kitty_editions }, null: true
    end
  end
end
