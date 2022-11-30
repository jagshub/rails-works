class AddIndexToModerationLogs < ActiveRecord::Migration
  def change
    add_index :moderation_logs, [:reference_id, :reference_type]
  end
end
