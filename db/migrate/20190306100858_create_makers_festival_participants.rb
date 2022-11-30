class CreateMakersFestivalParticipants < ActiveRecord::Migration[5.0]
  def change
    create_table :makers_festival_participants do |t|
      t.references :user, foreign_key: true, null: false
      t.references :makers_festival_category, foreign_key: true, null: false, index: { name: 'index_makers_festival_participant_on_category_id' }
      t.string :external_link
      t.integer :votes_count, null: false, default: 0 
      t.integer :credible_votes_count, null: false, default: 0
      t.jsonb :project_details, null: false, default: {}
      t.boolean :finalist, null: false, default: false
      t.boolean :winner, null: false, default: false
      t.integer :position

      t.timestamps
    end
  end
end
