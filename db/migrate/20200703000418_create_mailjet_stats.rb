class CreateMailjetStats < ActiveRecord::Migration[5.1]
  def change
    create_table :mailjet_stats do |t|
      t.string :campaign_name, null: false
      t.string :campaign_id, null: false
      t.integer :blocked_count, default: 0, null: false
      t.integer :bounced_count, default: 0, null: false
      t.integer :clicked_count, default: 0, null: false
      t.integer :delivered_count, default: 0, null: false
      t.integer :opened_count, default: 0, null: false
      t.integer :unsubscribed_count, default: 0, null: false
      t.integer :resolution, null: false
      t.datetime :sent_at, null: false
      t.datetime :timestamp, null: false

      t.timestamps
    end

    safety_assured do
      add_index :mailjet_stats, [:campaign_id, :resolution, :timestamp], unique: true, name: 'index_mailjet_stats_on_campaign_id_and_resolution_and_timestamp'
    end
  end
end
