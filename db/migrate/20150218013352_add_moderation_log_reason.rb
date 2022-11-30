class AddModerationLogReason < ActiveRecord::Migration
  def change
    add_column :moderation_logs, :reason, :text, null: true
  end
end
