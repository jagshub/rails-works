class AddAskCountersToUsers < ActiveRecord::Migration
  def change
    add_column :users, :product_requests_count, :integer, null: false, default: 0
    add_column :users, :recommendations_count, :integer, null: false, default: 0
    add_column :users, :user_follow_product_request_associations_count, :integer, null: false, default: 0
  end
end
