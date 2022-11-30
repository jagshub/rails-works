class CreateAmaEventSubscriptions < ActiveRecord::Migration
  def change
    create_table :ama_event_subscriptions do |t|
      t.references :user
      t.references :ama_event, null: false
      t.string :email
      t.integer :state, null: false, default: 0

      t.timestamps null: false
    end

    add_index :ama_event_subscriptions, %i(user_id ama_event_id), unique: true
  end
end
