class CreateDripMails < ActiveRecord::Migration[5.2]
  def change
    create_table :drip_mails do |t|
      t.references :user, foreign_key: true, index: true, null: false
      t.string :mailer_name, null: false
      t.string :drip_kind, null: false
      t.datetime :send_on, null: false
      t.boolean :completed, default: false
      t.datetime :sent_at, null: true
      t.datetime :opened_at, null: true
      t.datetime :clicked_at, null: true

      t.timestamps
    end

    add_index :drip_mails, :completed
    add_index :drip_mails, [:user_id, :mailer_name, :drip_kind], unique: true
  end
end
