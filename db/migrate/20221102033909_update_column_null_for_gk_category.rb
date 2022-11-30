class UpdateColumnNullForGkCategory < ActiveRecord::Migration[6.1]
  def change
    change_column_null :golden_kitty_categories, :tagline, true
    change_column_null :golden_kitty_categories, :nomination_question, true
  end
end
