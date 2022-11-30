# frozen_string_literal: true

class UpcomingPages::FetchActivities
  def self.call(upcoming_page:, limit: 20, offset: 0)
    new(upcoming_page).call(limit: limit, offset: offset)
  end

  attr_reader :upcoming_page

  def initialize(upcoming_page)
    @upcoming_page = upcoming_page
  end

  def call(limit: 20, offset: 0)
    ActiveRecord::Base.connection.exec_query(query_for(id: upcoming_page.id.to_i, limit: limit.to_i, offset: offset.to_i)).map do |row|
      Activity.new(upcoming_page, row)
    end
  end

  private

  class Activity
    attr_reader :upcoming_page, :subject, :subscriber, :created_at

    def initialize(upcoming_page, row)
      @upcoming_page = upcoming_page
      @subject = row['subject_type'].safe_constantize.find(row['subject_id'])
      @subscriber = UpcomingPageSubscriber.find(row['subscriber_id'])
      @created_at = Time.zone.parse(row['created_at'].to_s)
    end
  end

  def query_for(id:, limit:, offset:)
    <<-SQL
      SELECT subject_id, subject_type, subscriber_id, created_at
      FROM (
          SELECT upcoming_page_surveys.id AS subject_id, 'UpcomingPageSurvey' AS subject_type, upcoming_page_question_answers.upcoming_page_subscriber_id AS subscriber_id, MAX(upcoming_page_question_options.created_at) AS created_at
          FROM upcoming_page_question_answers
          INNER JOIN upcoming_page_question_options ON upcoming_page_question_options.id = upcoming_page_question_answers.upcoming_page_question_option_id
          INNER JOIN upcoming_page_questions ON upcoming_page_questions.id = upcoming_page_question_options.upcoming_page_question_id
          INNER JOIN upcoming_page_surveys ON upcoming_page_surveys.id = upcoming_page_questions.upcoming_page_survey_id
          WHERE upcoming_page_surveys.upcoming_page_id = #{ id }
          GROUP BY subject_id, subscriber_id
        UNION
          SELECT subject_id, 'UpcomingPageMessage' AS subject_type, upcoming_page_subscribers.id AS subscriber_id, MAX(comments.created_at)
          FROM comments
          INNER JOIN ship_contacts ON ship_contacts.user_id = comments.user_id
          INNER JOIN upcoming_page_subscribers ON upcoming_page_subscribers.ship_contact_id = ship_contacts.id AND upcoming_page_subscribers.upcoming_page_id = #{ id }
          WHERE comments.hidden_at IS NULL
          AND comments.subject_type = 'UpcomingPageMessage'
          AND comments.subject_id IN (
            SELECT upcoming_page_messages.id FROM upcoming_page_messages WHERE upcoming_page_messages.upcoming_page_id = #{ id }
          )
          GROUP BY subject_id, subscriber_id
        UNION
          SELECT upcoming_page_conversations.upcoming_page_message_id AS subject_id, 'UpcomingPageMessage' AS subject_type, upcoming_page_conversation_messages.upcoming_page_subscriber_id AS subscriber_id, MAX(upcoming_page_conversation_messages.created_at) AS created_at
          FROM upcoming_page_conversation_messages
          INNER JOIN upcoming_page_conversations ON upcoming_page_conversations.id = upcoming_page_conversation_messages.upcoming_page_conversation_id
          WHERE upcoming_page_conversations.trashed_at IS NULL
          AND upcoming_page_conversations.upcoming_page_id = #{ id }
          AND upcoming_page_conversation_messages.upcoming_page_subscriber_id IS NOT NULL
          GROUP BY subject_id, subscriber_id
      ) a
      ORDER BY created_at DESC
      LIMIT #{ limit }
      OFFSET #{ offset }
    SQL
  end
end
