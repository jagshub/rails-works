# frozen_string_literal: true

module Payments::Errors
  class MultipleActiveSubscriptionsForPlanError < StandardError; end
  class HasActiveSubscriptionInProjectError < StandardError; end
  class InvalidProjectError < StandardError; end
  class InvalidPlanError < StandardError; end
  class InvalidSubscriptionIdError < StandardError; end
end
