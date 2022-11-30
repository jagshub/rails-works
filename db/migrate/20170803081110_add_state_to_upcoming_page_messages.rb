class AddStateToUpcomingPageMessages < ActiveRecord::Migration
  def change
    change_table :upcoming_page_messages do |t|
      t.integer :state, default: 0, null: false
    end
  end
end
