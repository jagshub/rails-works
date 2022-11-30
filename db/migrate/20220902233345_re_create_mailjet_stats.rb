class ReCreateMailjetStats < ActiveRecord::Migration[6.1]
  def up
    # NOTE(DZ): Drop with cascade
    drop_table :mailjet_stats, if_exists: true, force: :cascade

    create_table :mailjet_stats do |t|
      t.string :campaign_id, null: false
      t.string :campaign_name, null: false
      t.date :date, null: false

      t.integer :event_click_delay, default: 0, null: false
      t.integer :event_clicked_count, default: 0, null: false
      t.integer :event_open_delay, default: 0, null: false
      t.integer :event_opened_count, default: 0, null: false
      t.integer :event_spam_count, default: 0, null: false
      t.integer :event_unsubscribed_count, default: 0, null: false
      t.integer :event_workflow_exited_count, default: 0, null: false
      t.integer :message_blocked_count, default: 0, null: false
      t.integer :message_clicked_count, default: 0, null: false
      t.integer :message_deferred_count, default: 0, null: false
      t.integer :message_hard_bounced_count, default: 0, null: false
      t.integer :message_opened_count, default: 0, null: false
      t.integer :message_queued_count, default: 0, null: false
      t.integer :message_sent_count, default: 0, null: false
      t.integer :message_soft_bounced_count, default: 0, null: false
      t.integer :message_spam_count, default: 0, null: false
      t.integer :message_unsubscribed_count, default: 0, null: false
      t.integer :message_work_flow_exited_count, default: 0, null: false

      t.timestamps
    end

    add_index :mailjet_stats, %i(campaign_id date), unique: true
  end

  def down
    drop_table :mailjet_stats
  end
end
