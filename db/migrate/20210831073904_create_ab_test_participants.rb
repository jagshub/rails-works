class CreateAbTestParticipants < ActiveRecord::Migration[5.2]
  def change
    create_table :ab_test_participants do |t|
      t.references :ab_test_experiment, foreign_key: true, null: false, index: false
      t.string :variant, null: false
      t.references :user, foreign_key: true, null: true
      t.string :visitor_id, null: true
      t.string :anonymous_id, null: true
      t.datetime :completed_at, null: true

      t.timestamps
    end

    add_index :ab_test_participants, %i(ab_test_experiment_id user_id variant), where: 'user_id is not null', name: 'index_abtest_participant_on_exp_user_variant'
    add_index :ab_test_participants, %i(ab_test_experiment_id visitor_id variant), where: 'visitor_id is not null', name: 'index_abtest_participant_on_exp_visitor_variant'
  end
end
