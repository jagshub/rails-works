class CreateEmailDigests < ActiveRecord::Migration
  def change
    create_table :email_digests do |t|
      t.references :subscriber, null: false, foreign_key: false, index: true
      t.integer :frequency, null: false, default: 0, index: true
      t.integer :state, null: false, default: 0

      t.timestamps null: false
    end

    create_table :email_digest_subscriptions do |t|
      t.references :email_digest, null: false, foreign_key: false, index: true
      t.references :subject, polymorphic: true, foreign_key: false, null: false

      t.timestamps null: false
    end

    create_table :email_digest_deliveries do |t|
      t.references :email_digest, null: false, foreign_key: false
      t.string :key, null: false, index: true
      t.jsonb :content, null: false
      t.integer :state, null: false, default: 0

      t.timestamps null: false
    end
  end
end
