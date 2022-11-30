class AddPublicFlagToModerationLog < ActiveRecord::Migration
  def change
    add_column :moderation_logs, :share_public, :boolean, default: false, null: false
  end
end
