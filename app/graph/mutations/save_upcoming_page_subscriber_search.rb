# frozen_string_literal: true

module Graph::Mutations
  class SaveUpcomingPageSubscriberSearch < BaseMutation
    argument :id, ID, required: false
    argument_record :upcoming_page, UpcomingPage, authorize: ApplicationPolicy::MAINTAIN, required: true
    argument :filters, [Graph::Types::UpcomingPageSubscriberFilterInputType], required: true
    argument :name, String, required: false

    returns Graph::Types::UpcomingPageSubscriberSearchType

    def perform(id: nil, upcoming_page:, filters:, name: nil)
      search = upcoming_page.subscriber_searches.find_by id: id if id.present?
      search = upcoming_page.subscriber_searches.build if search.blank?

      search.update name: name, filters: filters.map(&:to_h)
      search
    end
  end
end
