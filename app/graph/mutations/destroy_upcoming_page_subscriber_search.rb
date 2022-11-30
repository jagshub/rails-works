# frozen_string_literal: true

module Graph::Mutations
  class DestroyUpcomingPageSubscriberSearch < BaseMutation
    argument_record :search, UpcomingPageSubscriberSearch, required: true, authorize: ApplicationPolicy::MAINTAIN

    returns Graph::Types::UpcomingPageSubscriberSearchType

    def perform(search:)
      search.destroy!
      search
    end
  end
end
