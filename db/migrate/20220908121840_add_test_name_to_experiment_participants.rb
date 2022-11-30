class AddTestNameToExperimentParticipants < ActiveRecord::Migration[6.1]
  def change
    add_column :ab_test_participants, :test_name, :string, null: true, index: true

    change_column_null :ab_test_participants, :ab_test_experiment_id, true
  end
end
