# frozen_string_literal: true

module Graph::Resolvers
  class UpcomingPages::MessageMetricsResolver < Graph::Resolvers::Base
    type Graph::Types::UpcomingPageMessageMetricsType, null: true

    NO_MESSAGES = [0, 0, 0].freeze

    def resolve
      return unless ApplicationPolicy.can?(current_user, ApplicationPolicy::MAINTAIN, object)

      sent_count, opened_count, clicked_count = gather_metrics_for(object) || NO_MESSAGES

      return if sent_count.zero?

      OpenStruct.new(
        open_rate: opened_count.to_f / sent_count,
        click_rate: clicked_count.to_f / sent_count,
      )
    end

    private

    def gather_metrics_for(page)
      page
        .messages
        .map { |message| message_metrics_for(message) }
        .reduce { |acc, elem| [acc[0] + elem[0], acc[1] + elem[1], acc[2] + elem[2]] }
    end

    def message_metrics_for(message)
      count = message.sent_count
      if count.zero?
        [0, 0, 0]
      else
        [count, message.opened_count, message.clicked_count]
      end
    end
  end
end
