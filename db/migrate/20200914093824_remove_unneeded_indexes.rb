class RemoveUnneededIndexes < ActiveRecord::Migration[5.1]
  def change
    remove_index :ads_channels, name: "index_ads_channels_on_budget_id", column: :budget_id
    remove_index :anthologies_related_story_associations, name: "index_anthologies_related_story_associations_on_story_id", column: :story_id
    remove_index :collaborator_associations, name: "index_collaborator_associations_on_subject_type_and_subject_id", column: [:subject_type, :subject_id]
    remove_index :discussion_threads, name: "index_discussion_threads_on_user_id", column: :user_id
    remove_index :embeds, name: "index_embeds_on_subject_type_and_subject_id", column: [:subject_type, :subject_id]
    remove_index :founder_club_claims, name: "index_founder_club_claims_on_deal_id", column: :deal_id
    remove_index :founder_club_redemption_codes, name: "index_founder_club_redemption_codes_on_deal_id", column: :deal_id
    remove_index :golden_kitty_finalists, name: "index_golden_kitty_finalists_on_post_id", column: :post_id
    remove_index :golden_kitty_nominees, name: "index_golden_kitty_nominees_on_post_id", column: :post_id
    remove_index :golden_kitty_people, name: "index_golden_kitty_people_on_user_id", column: :user_id
    remove_index :link_spect_logs, name: "index_link_spect_logs_on_external_link", column: :external_link
    remove_index :maker_group_members, name: "index_maker_group_members_on_user_id", column: :user_id
    remove_index :maker_welcomes, name: "index_maker_welcomes_on_welcomer_id", column: :welcomer_id
    remove_index :makers_festival_makers, name: "index_makers_festival_makers_on_user_id", column: :user_id
    remove_index :mentions, name: "index_mentions_on_user_id", column: :user_id
    remove_index :onboardings, name: "index_onboardings_on_user_id", column: :user_id
    remove_index :poll_answers, name: "index_poll_answers_on_poll_option_id", column: :poll_option_id
    remove_index :ship_account_member_associations, name: "index_ship_account_member_associations_on_ship_account_id", column: :ship_account_id
    remove_index :ship_contacts, name: "index_ship_contacts_on_ship_account_id", column: :ship_account_id
    remove_index :topic_associations, name: "index_topic_associations_on_topic_id", column: :topic_id
    remove_index :upcoming_page_message_deliveries, name: "index_upcoming_page_message_deliveries_on_message_id", column: :upcoming_page_message_id
  end
end
