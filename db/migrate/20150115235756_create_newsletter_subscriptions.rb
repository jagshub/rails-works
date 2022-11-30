class CreateNewsletterSubscriptions < ActiveRecord::Migration
  def change
    create_table :newsletter_subscriptions do |t|
      t.integer :user_id, unique: true
      t.integer :frequency, default: 0, null: false
      t.string  :mailchimp_id
      t.string  :email, null: false
      t.boolean :subscribed, default: true, null: false

      t.timestamps null: false
    end

    add_index :newsletter_subscriptions, :user_id, unique: true
    add_index :newsletter_subscriptions, :mailchimp_id, unique: true
    add_index :newsletter_subscriptions, :email, unique: true
  end
end
