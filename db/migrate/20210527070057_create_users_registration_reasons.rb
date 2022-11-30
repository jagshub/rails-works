class CreateUsersRegistrationReasons < ActiveRecord::Migration[5.2]
  def change
    create_table :users_registration_reasons do |t|
      t.string :source_component, null: false
      t.string :origin_url
      t.string :app
      t.references :user, foreign_key: true, index: true, null: false

      t.timestamps
    end
  end
end
