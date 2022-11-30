class AddGroupToPaymentsPlan < ActiveRecord::Migration
  def change
    add_column :plans, :group, :integer, null: false, default: 0

    add_index :plans, [:group, :status]
  end
end
