class AddReferrerToUsers < ActiveRecord::Migration
  def change
    add_column :users, :referrer_id, :integer, nil: true
    add_index :users, :referrer_id
  end
end
