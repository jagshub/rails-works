class CreateUpcomingPageSubscribers < ActiveRecord::Migration
  def change
    create_table :upcoming_page_subscribers do |t|
      t.string :email, null: false
      t.string :token, null: false

      t.boolean :email_confirmed, default: false

      t.references :upcoming_page, null: false
      t.references :user

      t.timestamps null: false
    end

    add_index :upcoming_page_subscribers, [:upcoming_page_id, :email], unique: true
  end
end
