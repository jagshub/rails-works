class AddCachedFieldsToActivityEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :product_activity_events, :votes_count,       :integer, null: false, default: 0
    add_column :product_activity_events, :comments_count,    :integer, null: false, default: 0
    add_column :product_activity_events, :nominations_count, :integer, null: false, default: 0

    add_column :product_activity_events, :title, :string, null: true
  end
end
