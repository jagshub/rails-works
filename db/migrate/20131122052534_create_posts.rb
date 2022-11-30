class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.references :user, index: true
      t.string :name
      t.string :tagline
      t.integer :clicks

      t.timestamps
    end
  end
end
