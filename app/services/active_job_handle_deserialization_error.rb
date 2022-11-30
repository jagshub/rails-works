# frozen_string_literal: true

module ActiveJobHandleDeserializationError
  include ActiveJobRetriesCount

  extend ActiveSupport::Concern

  included do
    # NOTE(rstankov): Some time job is executed, before record is commit to database
    rescue_from ActiveJob::DeserializationError do
      retry_job wait: 5.minutes if retries_count.zero?
    end
  end
end
