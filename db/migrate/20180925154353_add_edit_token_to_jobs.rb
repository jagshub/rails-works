class AddEditTokenToJobs < ActiveRecord::Migration[5.0]
  def change
    add_column :jobs, :token, :string, null: true
    add_index :jobs, :token, unique: true
  end
end
