class CreateSocialDigest < ActiveRecord::Migration
  def change
    create_table :social_digests do |t|
      t.integer :user_id, null: false
      t.date :date, null: false
      t.timestamps null: false
    end

    add_index :social_digests, %i(user_id date)
  end
end
