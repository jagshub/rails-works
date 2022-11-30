class AddEmojiToTopics < ActiveRecord::Migration[5.1]
  def change
    add_column :topics, :emoji, :string, null: true
  end
end
