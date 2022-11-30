class AddPostToReview < ActiveRecord::Migration[6.1]
  def up
    remove_index :reviews, :post_id, if_exists: true

    if !ActiveRecord::Base.connection.column_exists?(:reviews, :post_id)
      add_reference :reviews, :post, foreign_key: true, index: false
    end
  end

  def down
    remove_reference :reviews, :post
  end
end
