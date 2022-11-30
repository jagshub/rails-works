# frozen_string_literal: true

module ActiveJobHandlePostgresErrors
  include ActiveJobRetriesCount

  extend ActiveSupport::Concern

  ERRORS = [
    ActiveRecord::ConnectionNotEstablished,
    ActiveRecord::ConnectionTimeoutError,
    ActiveRecord::Deadlocked,
    ActiveRecord::QueryCanceled,
    PG::InFailedSqlTransaction,
    PG::LockNotAvailable,
    PG::TRDeadlockDetected,
  ].freeze

  ERROR_STATEMENTS = [
    'deadlock detected',
    'could not obtain lock',
    'current transaction is aborted',
    'no connection to the server',
  ].freeze

  included do
    rescue_from(*ERRORS) do |exception|
      if retries_count <= 10
        retry_job wait: 5.minutes
      else
        ErrorReporting.report_warning(exception)
      end
    end

    rescue_from(ActiveRecord::StatementInvalid) do |exception|
      raise exception unless ERROR_STATEMENTS.any? { |message| exception.message.include?(message) }

      if retries_count <= 10
        retry_job wait: 5.minutes
      else
        ErrorReporting.report_warning(exception)
      end
    end
  end
end
