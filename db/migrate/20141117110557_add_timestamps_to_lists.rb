class AddTimestampsToLists < ActiveRecord::Migration
  def change
    change_table :lists do |t|
      t.timestamps
    end
  end
end
