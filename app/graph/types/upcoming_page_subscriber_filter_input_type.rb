# frozen_string_literal: true

module Graph::Types
  class UpcomingPageSubscriberFilterInputType < BaseInputObject
    argument :type, String, required: false
    argument :value, String, required: false
  end
end
