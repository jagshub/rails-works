class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :username
      t.string :twitter_uid
      t.string :image
      t.string :headline
      t.boolean :daily_email

      t.timestamps
    end
  end
end
