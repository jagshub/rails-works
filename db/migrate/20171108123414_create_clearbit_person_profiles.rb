class CreateClearbitPersonProfiles < ActiveRecord::Migration[5.0]
  def change
    create_table :clearbit_person_profiles do |t|
      t.string :clearbit_id, null: false
      t.string :email, null: false
      t.datetime :indexed_at, null: false

      t.string :name, null: true
      t.string :gender, null: true
      t.text :bio, null: true
      t.string :site, null: true
      t.string :avatar_url, null: true

      t.string :employment_name, null: true
      t.string :employment_title, null: true
      t.string :employment_domain, null: true

      t.string :geo_city, null: true
      t.string :geo_state, null: true
      t.string :geo_country, null: true

      t.string :github_handle, null: true
      t.string :twitter_handle, null: true
      t.string :linkedin_handle, null: true
      t.string :gravatar_handle, null: true
      t.string :aboutme_handle, null: true

      t.timestamps null: false
    end

    add_index :clearbit_person_profiles, :clearbit_id, unique: true
    add_index :clearbit_person_profiles, :email, unique: true
  end
end
