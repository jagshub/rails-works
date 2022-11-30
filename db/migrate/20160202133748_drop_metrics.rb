class DropMetrics < ActiveRecord::Migration
  def change
    drop_table 'metrics'
  end
end
