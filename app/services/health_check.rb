# frozen_string_literal: true

require 'sidekiq/api'

class HealthCheck
  class << self
    def call
      output = []
      all_ok = true

      begin
        # Simple DB connection test
        ActiveRecord::Base.connection.execute('SELECT 1')

        # Check worker queue is fine
        queue = Sidekiq::Queue.new
        if queue.latency > 15.minutes
          output << 'QUEUE_BACKLOGGED'
          all_ok = false
        end

        # Insert future checks here
      rescue StandardError => e
        output << "ERROR #{ e.message }"
        all_ok = false
      end

      output << 'ALL_OK' if all_ok
      output << "(items: #{ queue.size }, latency: #{ queue.latency } seconds)" if queue.present?

      [all_ok, output.join("\n")]
    end
  end
end
