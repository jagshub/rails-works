class DropMeetupEvents < ActiveRecord::Migration[6.1]
  def up
    drop_table :meetup_events, force: :cascade
  end

  def down ## Migration Not reversible
    fail ActiveRecord::IrreversibleMigration
  end
end
