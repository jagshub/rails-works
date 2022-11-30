class AddEnrichedTweetToSipSlide < ActiveRecord::Migration[5.0]
  def change
    add_column :sip_slides, :enriched_tweet, :jsonb
  end
end
