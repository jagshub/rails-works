class AddUniqueIndexToMetrics < ActiveRecord::Migration
  def change
    execute 'commit;'
    remove_index :metrics, name: "index_metrics_on_name_and_date"
    add_index :metrics, [:name, :date], unique: true, algorithm: :concurrently
    execute 'begin;'
  end
end
