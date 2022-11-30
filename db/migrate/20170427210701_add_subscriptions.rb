class AddSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.references :subscriber, null: false
      t.references :subject, polymorphic: true, foreign_key: false
      t.integer :state, null: false, default: 0

      t.timestamps null: false

      t.index([:state, :subject_type, :subject_id, :subscriber_id], unique: true, name: :index_subscriptions_on_subject_and_subscriber)
    end
  end
end
