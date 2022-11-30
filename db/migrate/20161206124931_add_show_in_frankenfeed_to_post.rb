class AddShowInFrankenfeedToPost < ActiveRecord::Migration
  def change
    add_column :posts, :show_in_frankenfeed, :boolean, default: true, null: false
  end
end
