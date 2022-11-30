# frozen_string_literal: true

module HandleRaceCondition
  extend self

  UNIQUE_ACTIVE_RECORD_ERROR = 'has already been taken'

  def call(max_retries: 2, ignore: false, transaction: false)
    retries ||= max_retries
    if transaction
      ActiveRecord::Base.transaction do
        yield
      end
    else
      yield
    end
  rescue ActiveRecord::RecordNotUnique, PG::UniqueViolation, PG::InFailedSqlTransaction, ActiveRecord::Deadlocked, PG::TRDeadlockDetected
    retries -= 1

    raise unless retries.nonzero?

    retry unless ignore
  rescue ActiveRecord::RecordInvalid => e
    raise unless e.message.include? UNIQUE_ACTIVE_RECORD_ERROR

    retries -= 1
    raise unless retries.nonzero?

    retry unless ignore
  end
end
