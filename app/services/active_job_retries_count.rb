# frozen_string_literal: true

module ActiveJobRetriesCount
  extend ActiveSupport::Concern

  included do
    attr_accessor :retries_count
  end

  def initialize(*arguments)
    super
    @retries_count ||= 0
  end

  def deserialize(job_data)
    super
    @retries_count = job_data['retries_count'] || 0
  end

  def serialize
    hash = super.merge(
      'retries_count' => retries_count || 0,
    )

    # NOTE(rstankov): Workaround for Rails bug
    #   When arguments raise `ActiveJob::DeserializationError` arguments are blank
    hash['arguments'] = @serialized_arguments if hash['arguments'].blank? && @serialized_arguments.present?

    hash
  end

  def retry_job(options)
    @retries_count = (retries_count || 0) + 1
    super(options)
  end
end
