# frozen_string_literal: true

module Jobs::Downgrade
  extend self

  def call(job)
    job.update!(published: false, cancelled_at: Time.current)
  end
end
