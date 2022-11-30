# frozen_string_literal: true

module Graph::Mutations
  class CreateUpcomingPageMessage < BaseMutation
    argument :id, ID, required: false
    argument :subject, String, required: false
    argument :kind, String, required: false
    argument :layout, String, required: false
    argument :visibility, String, required: false
    argument :body, Graph::Types::HTMLType, required: false
    argument :state, String, required: false
    argument :send_test, Boolean, required: false
    argument :subscriber_filters, [Graph::Types::UpcomingPageSubscriberFilterInputType], required: false
    argument :upcoming_page_id, ID, required: false
    argument :user_id, ID, required: false
    argument :upcoming_page_survey_id, ID, required: false
    argument :post_id, ID, required: false

    returns Graph::Types::UpcomingPageMessageType

    def perform(inputs)
      values = inputs
      values[:subscriber_filters] = values[:subscriber_filters].map(&:to_h).map(&:stringify_keys) if values[:subscriber_filters]

      form = ::UpcomingPages::Messages::CreateForm.new(user: current_user, inputs: inputs)
      form.update values
      form
    end
  end
end
