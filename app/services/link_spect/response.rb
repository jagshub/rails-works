# frozen_string_literal: true

module LinkSpect::Response
  extend self

  def blocked?(responses, source = nil, create_log = false)
    block = responses.any?(&:blocked)
    batch_create(responses) if (block || create_log) && source.present?

    block
  end

  class Log
    attr_reader :blocked, :external_link, :source, :expires_at

    def initialize(blocked:, external_link:, source:, expires_at:)
      @blocked = blocked
      @external_link = external_link
      @source = source
      @expires_at = expires_at
    end
  end

  private

  def batch_create(responses)
    responses.each do |response|
      LinkSpect::Log.create! response.instance_values
    end
  end
end
