class DropNotices < ActiveRecord::Migration
  def change
    drop_table :notices
  end
end
