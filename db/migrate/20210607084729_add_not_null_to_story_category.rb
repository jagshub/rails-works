class AddNotNullToStoryCategory < ActiveRecord::Migration[5.2]
  def change
    change_column_null :anthologies_stories, :category, false
  end
end
