class CreateAbTestExperiments < ActiveRecord::Migration[5.2]
  def change
    create_table :ab_test_experiments do |t|
      t.string :name, null: false
      t.datetime :start_date
      t.datetime :end_date

      t.timestamps
    end

    add_index :ab_test_experiments, :name, unique: true
  end
end
