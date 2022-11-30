class AddNoticeTimestamps < ActiveRecord::Migration
  class Notice < ApplicationRecord
  end

  def up
    add_timestamps :notices, null: true

    Notice.update_all created_at: Time.zone.now, updated_at: Time.zone.now

    change_column_null :notices, :created_at, false
    change_column_null :notices, :updated_at, false
  end

  def down
    remove_timestamps :notices
  end
end
