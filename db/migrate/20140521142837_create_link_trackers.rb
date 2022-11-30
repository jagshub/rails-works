class CreateLinkTrackers < ActiveRecord::Migration
  def change
    create_table :link_trackers do |t|
      t.integer :post_id
      t.integer :user_id
      t.string :track_code
      t.string :ip_address
      t.string :from_url
      t.string :to_url

      t.timestamps
    end
  end
end
