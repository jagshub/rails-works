# frozen_string_literal: true

class AddDefaultNullFalseToPostReviewWithBodyCounterCache < ActiveRecord::Migration[5.1]
  def change
    safety_assured do
      change_column_default :posts, :reviews_with_body_count, from: 0, to: 0
      change_column_null :posts, :reviews_with_body_count, false, 0
    end
  end
end
