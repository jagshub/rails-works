class CreateMakerFestParticipants < ActiveRecord::Migration[5.0]
  def change
    create_table :maker_fest_participants do |t|
      t.integer :category_slug, null: false, default: 0
      t.references :user, foreign_key: true, null: false
      t.references :upcoming_page, foreign_key: true, null: false
      t.integer :votes_count, null: false, default: 0
      t.integer :credible_votes_count, null: false, default: 0
      t.string :external_link, null: false

      t.timestamps
    end
  end
end
