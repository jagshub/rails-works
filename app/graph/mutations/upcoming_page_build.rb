# frozen_string_literal: true

module Graph::Mutations
  class UpcomingPageBuild < BaseMutation
    returns Graph::Types::UpcomingPageType

    require_current_user

    def perform
      form = ::UpcomingPages::Form.new(current_user)
      form.update ::UpcomingPages::Defaults.call(current_user)
      form
    end
  end
end
