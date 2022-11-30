class AddDataToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :data, :json, null: false, default: {}
  end
end
