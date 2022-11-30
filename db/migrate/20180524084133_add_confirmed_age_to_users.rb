class AddConfirmedAgeToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :confirmed_age, :boolean, null: false, default: false
  end
end
