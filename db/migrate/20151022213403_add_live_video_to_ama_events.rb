class AddLiveVideoToAmaEvents < ActiveRecord::Migration
  def change
    add_column :ama_events, :live_video, :boolean, default: false, null: false
  end
end
