class DropSlateColumns < ActiveRecord::Migration[5.0]
  def change
    remove_column :collection_post_associations, :description
    remove_column :teams, :about_text
    remove_column :collections, :intro
    remove_column :collections, :recap
    remove_column :goals, :title
    remove_column :chat_rooms, :description
    remove_column :chat_messages, :text
    remove_column :reviews, :pros
    remove_column :reviews, :cons
    remove_column :reviews, :body
    remove_column :posts, :description
    remove_column :maker_groups, :instructions
    remove_column :upcoming_pages, :success_text
    remove_column :upcoming_page_variants, :who_text
    remove_column :upcoming_page_variants, :what_text
    remove_column :upcoming_page_variants, :why_text
    remove_column :upcoming_page_surveys, :description
    remove_column :upcoming_page_surveys, :success_text
    remove_column :upcoming_page_surveys, :welcome_text
    remove_column :upcoming_page_messages, :body
  end
end
