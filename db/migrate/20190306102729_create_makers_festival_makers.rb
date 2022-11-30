class CreateMakersFestivalMakers < ActiveRecord::Migration[5.0]
  def change
    create_table :makers_festival_makers do |t|
      t.references :user, foreign_key: true, null: false
      t.references :makers_festival_participant, foreign_key: true, null: false, index: { name: 'index_makers_festival_makers_on_participant_id' }

      t.timestamps
    end

    add_index :makers_festival_makers, %i(user_id makers_festival_participant_id), unique: true, name: 'index_makers_festival_makers_on_user_id_participant_id'
  end
end
