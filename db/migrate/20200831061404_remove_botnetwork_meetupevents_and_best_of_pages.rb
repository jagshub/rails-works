class RemoveBotnetworkMeetupeventsAndBestOfPages < ActiveRecord::Migration[5.1]
  def change
    drop_table :best_of_pages
    drop_table :best_of_page_collection_associations
    drop_table :best_of_page_post_associations
    drop_table :best_of_page_product_request_associations
    drop_table :best_of_page_related_best_of_page_associations
    drop_table :bot_networks
    drop_table :meetup_event_tag_associations
    drop_table :meetup_event_tags
    drop_table :meetup_event_speaker_associations
    drop_table :meetup_event_host_associations
    drop_table :meetup_events
  end
end
