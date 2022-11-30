class DropAbTestExperiment < ActiveRecord::Migration[6.1]
  def change
    drop_table :ab_test_experiments, force: :cascade, if_exists: true
  end
end
