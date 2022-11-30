class CreateUserLinks < ActiveRecord::Migration[6.1]
  def change
    create_table :users_links do |t|
      t.string :name, null: false
      t.string :url, null: false
      t.string :kind, null: false, default: 'website'
      t.belongs_to :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
