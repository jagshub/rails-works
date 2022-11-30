class AddAuthorColumnToStories < ActiveRecord::Migration[6.1]
  def change
    add_column :anthologies_stories, :author_name, :string, null: true
    add_column :anthologies_stories, :author_url, :string, null: true
  end
end
