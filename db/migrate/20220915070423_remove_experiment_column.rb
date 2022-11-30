class RemoveExperimentColumn < ActiveRecord::Migration[6.1]
  def up
    safety_assured { remove_column :ab_test_participants, :ab_test_experiment_id }
  end

  def down
    add_reference :ab_test_participants, :ab_test_experiment, null: true, index: false
  end
end
