# frozen_string_literal: true

class AddFullReviewsCountToPost < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :reviews_with_body_count, :integer
  end
end
