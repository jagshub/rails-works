class AddTopicIdToPlatforms < ActiveRecord::Migration
  def change
    add_column :platforms, :topic_id, :integer, null: true
  end
end
