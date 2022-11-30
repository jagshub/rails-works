class CreateSubmissions < ActiveRecord::Migration
  def change
    drop_table :submissions if self.table_exists?('submissions')

    create_table :submissions do |t|
      t.string :name
      t.integer :user_id
      t.string :tagline
      t.text :comment

      t.timestamps
    end
  end
end
