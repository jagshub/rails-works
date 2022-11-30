class AddUrlClickCountToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :url_click_count, :integer, default: 0, null: false
  end
end
