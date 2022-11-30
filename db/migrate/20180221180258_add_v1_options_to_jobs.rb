class AddV1OptionsToJobs < ActiveRecord::Migration[5.0]
  def change
    # NOTE (k1): At time of migration, all jobs are AL-imported, we needt o update the default to be "in-house" after initially setting them all to "angellist"
    add_column :jobs, :kind, :integer, default: 10, null: false
    change_column_default :jobs, :kind, from: 10, to: 0

    add_column :jobs, :premium, :boolean, default: false, null: false
    add_column :jobs, :standard, :boolean, default: false, null: false

    add_index :jobs, [:published, :standard]
    add_index :jobs, [:premium]
  end
end
