class AddReceivedAtToStreamEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :stream_events, :received_at, :datetime
  end
end
