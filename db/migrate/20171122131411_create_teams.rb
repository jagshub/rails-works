class CreateTeams < ActiveRecord::Migration[5.0]
  def change
    create_table :teams do |t|
      t.references :ship_subscription, null: false

      t.string :name, null: false
      t.string :slug, null: false

      t.string :location, null: false
      t.string :tagline, null: false

      t.integer :status, null: false, default: 0
      t.string :team_size, null: false

      t.string :logo_uuid
      t.string :header_image_uuid

      t.string :website_url, null: false
      t.string :blog_url
      t.string :twitter_url
      t.string :facebook_url
      t.string :angellist_url
      t.string :instagram_url
      t.string :github_url
      t.string :linkedin_url
      t.string :crunch_base_url

      t.timestamps null: false
    end


    add_foreign_key :teams, :ship_subscriptions
    add_index :teams, :slug, unique: true
  end
end
