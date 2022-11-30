class AddBetaTesterToUsers < ActiveRecord::Migration
  def change
    add_column :users, :beta_tester, :boolean, null: false, default: false
  end
end
