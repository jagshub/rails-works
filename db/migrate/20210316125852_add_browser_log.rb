class AddBrowserLog < ActiveRecord::Migration[5.1]
  def change
    create_table :users_browser_logs do |t|
      t.belongs_to :user, index: { unique: true }, foreign_key: true, null: false
      t.string :browsers, null: true, array: true, default: []
      t.string :devices, null: true, array: true, default: []
      t.string :platforms, null: true, array: true, default: []
      t.string :countries, null: true, array: true, default: []
      t.timestamps
    end

    add_column :users, :last_user_agent, :string, null: true
  end
end
