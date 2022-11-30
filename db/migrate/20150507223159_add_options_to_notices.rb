class AddOptionsToNotices < ActiveRecord::Migration
  def change
    add_column :notices, :options, :json, null: false, default: {}
  end
end
