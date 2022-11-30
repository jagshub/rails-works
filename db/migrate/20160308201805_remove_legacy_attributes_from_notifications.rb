class RemoveLegacyAttributesFromNotifications < ActiveRecord::Migration
  def up
    remove_columns :notifications, :post_id, :seen, :comment_id, :type
    change_column_null :notifications, :created_at, false
    change_column_null :notifications, :updated_at, false
    change_column_null :notifications, :notifyable_type, false
    change_column_null :notifications, :notifyable_id, false
  end

  def down
    add_column :notifications, :post_id, :integer, null: true
    add_column :notifications, :seen, :bool, null: true
    add_column :notifications, :comment_id, :integer, null: true
    add_column :notifications, :type, :string, null: true
  end
end
