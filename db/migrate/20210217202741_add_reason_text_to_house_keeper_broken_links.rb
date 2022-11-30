class AddReasonTextToHouseKeeperBrokenLinks < ActiveRecord::Migration[5.1]
  def change
    add_column :house_keeper_broken_links, :reason, :text
  end
end
