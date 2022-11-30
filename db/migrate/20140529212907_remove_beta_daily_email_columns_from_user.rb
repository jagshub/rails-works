class RemoveBetaDailyEmailColumnsFromUser < ActiveRecord::Migration
  def self.up
    remove_column :users, :beta
    remove_column :users, :daily_email
  end

  def self.down
    add_column :users, :beta, :boolean
    add_column :users, :daily_email, :boolean
  end
end
