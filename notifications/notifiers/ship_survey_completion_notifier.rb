# frozen_string_literal: true

module Notifications::Notifiers::ShipSurveyCompletionNotifier
  extend Notifications::Notifiers::BaseNotifier
  extend self

  def channels
    {
      slack: {
        priority: :mandatory,
        user_setting: false,
      },
    }
  end

  def subscriber_ids(answer)
    answer
      .upcoming_page.maintainers
      .select { |user| SlackBot.active_for?(user) }
      .map { |user| user.subscriber&.id }
      .compact
  end

  class SlackPayload < Notifications::Channels::Slack::Payload
    def text
      "#{ pick_salutation } A subscriber filled in a survey."
    end

    def icon_emoji
      ':boat:'
    end

    def attachments
      answer = notification.notifyable
      subscriber = answer.subscriber

      return [] unless subscriber

      url = Routes.my_ship_survey_answer_url(answer.upcoming_page_survey_id, subscriber.id)

      [attachment(
        author_icon: subscriber.avatar_url,
        author_link: Routes.my_ship_contact_url(subscriber.ship_contact_id),
        author_name: subscriber.name,
        fields: attachment_fields_for(answer),
        footer: subscriber.upcoming_page.name,
        title: answer.survey_title,
        title_link: url,
        ts: answer.created_at.to_i,
        actions: [
          action('View details', url),
        ],
      )]
    end

    private

    def attachment_fields_for(answer)
      UpcomingPageQuestionAnswer
        .includes(:option, :question)
        .where('upcoming_page_questions.upcoming_page_survey_id' => answer.question.upcoming_page_survey_id)
        .where(upcoming_page_subscriber_id: answer.upcoming_page_subscriber_id)
        .order('upcoming_page_questions.position_in_survey ASC')
        .map { |a| [a.question.id, a.question.title, a.value] }
        .each_with_object({}) do |(id, question, value), acc|
        if acc[id]
          acc[id][:value] = "#{ acc[id][:value] }, #{ value }".truncate(40)
        else
          acc[id] = attachment_field question, value, short: false
        end
        acc
      end.values
    end
  end
end
