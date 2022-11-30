class CreateIterableEventWebhookData < ActiveRecord::Migration[6.1]
  def change
    create_table :iterable_event_webhook_data do |t|
      t.string :event_name, null: false, index: true
      t.string :email
      t.string :workflow_name
      t.string :campaign_name
      t.jsonb :data_fields

      t.timestamps
    end
  end
end
