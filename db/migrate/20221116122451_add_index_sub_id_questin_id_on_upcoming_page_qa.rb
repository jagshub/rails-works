class AddIndexSubIdQuestinIdOnUpcomingPageQa < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    return if Rails.env.production?

    add_index :upcoming_page_question_answers, [:upcoming_page_subscriber_id,:upcoming_page_question_option_id],
              name: 'index_subscriber_id_question_option_id' , algorithm: :concurrently, if_not_exists: true
  end
end
