class AddPollCounters < ActiveRecord::Migration[5.1]
  def change
    add_column :polls, :options_count, :integer, null: false, default: 0
    add_column :polls, :answers_count, :integer, null: false, default: 0
    add_column :poll_options, :answers_count, :integer, null: false, default: 0
  end
end
