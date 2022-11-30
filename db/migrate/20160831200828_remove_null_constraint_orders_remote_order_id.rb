class RemoveNullConstraintOrdersRemoteOrderId < ActiveRecord::Migration
  def change
    change_column_null(:orders, :remote_order_id, true)
  end
end
