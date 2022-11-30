class CreateEmails < ActiveRecord::Migration[5.0]
  def change
    create_table :emails do |t|
      t.citext :email, index: true, null: false, unique: true
      t.string :source

      t.timestamps
    end
  end
end
