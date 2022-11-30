class CreatePostVotes < ActiveRecord::Migration
  def change
    create_table :post_votes do |t|
      t.references :user, index: true
      t.references :post, index: true

      t.timestamps
    end
  end
end
