class AddTrackingSourceToUpcomingSubscribers < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    change_table :upcoming_page_subscribers do |t|
      t.string :source_kind, null: true
      t.string :source_reference_id, null: true
    end

    add_index :upcoming_page_subscribers, :source_kind, algorithm: :concurrently
  end
end
