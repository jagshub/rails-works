class AddBrowsersToNotices < ActiveRecord::Migration
  def change
    add_column :notices, :browsers, :text, array: true, default: []
  end
end
