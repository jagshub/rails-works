class AddBetaToUser < ActiveRecord::Migration
  def change
    add_column :users, :beta, :boolean
  end
end
