class AddUpcomingPageQuestionOptionIdToUpcomingPageMessages < ActiveRecord::Migration
  def change
    add_reference :upcoming_page_messages, :upcoming_page_question_option
    add_index :upcoming_page_messages, :upcoming_page_question_option_id, name: ':upcoming_page_messages_on_option_id'
    add_foreign_key :upcoming_page_messages, :upcoming_page_question_options
  end
end
