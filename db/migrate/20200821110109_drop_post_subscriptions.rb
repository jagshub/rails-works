class DropPostSubscriptions < ActiveRecord::Migration[5.1]
  def change
    safety_assured do
      remove_column :posts, :subscribers_count
      drop_table :post_subscribers
    end
  end
end
