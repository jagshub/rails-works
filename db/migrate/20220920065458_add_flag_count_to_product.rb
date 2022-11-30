class AddFlagCountToProduct < ActiveRecord::Migration[6.1]
  def change
    add_column :products, :user_flags_count, :integer, default: 0, null: false
  end
end
