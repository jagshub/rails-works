class AddNewVersionToProducts < ActiveRecord::Migration
  def change
    add_column :products, :new_version, :boolean, default: :false, null: false
  end
end
