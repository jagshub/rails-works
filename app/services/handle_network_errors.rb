# frozen_string_literal: true

module HandleNetworkErrors
  extend self

  def call(fallback:)
    yield
  rescue *ActiveJobHandleNetworkErrors::HTTP_ERRORS => _e # rubocop:disable Naming/RescuedExceptionsVariableName
    fallback
  end
end
