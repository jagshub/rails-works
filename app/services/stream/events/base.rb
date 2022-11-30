# frozen_string_literal: true

module Stream
  class Events::Base < ApplicationJob
    include ActiveJobHandleDeserializationError

    def perform(event_attrs)
      event_attrs[:received_at] = Time.zone.at(event_attrs[:received_at])
      event = Stream::Event.create!(event_attrs)

      workers = fetch_fanout_workers(event)
      return if workers.empty? || !should_fanout(event)

      workers.each { |worker| worker.perform_later(event) if worker.respond_to?(:perform_later) }
    end

    def should_fanout(_event)
      # NOTE(Dhruv): Fanout all workers by default.
      true
    end

    def fetch_fanout_workers(_event)
      []
    end

    class << self
      DEFAULT_KEYS_TO_EXTRACT_FROM_PAYLOAD = %i(
        browser
        device_type
        os
        os_version
        referer
        first_referer
        request_ip
        user_agent
        visit_duration
        oauth_application_id
      ).freeze

      attr_reader :workers

      def normalize_payload(payload)
        return {} if payload.blank?

        keys = DEFAULT_KEYS_TO_EXTRACT_FROM_PAYLOAD + (@extra_keys_in_payload || [])
        payload = payload.slice(*keys)
        payload.each { |k, v| payload[k] = v.to_s if v.is_a?(Symbol) }

        payload
      end

      def event_name(name) # rubocop:disable Style/TrivialAccessors
        @event_name = name
      end

      def allowed_subjects(subjects = [])
        @allowed_subjects = subjects
      end

      def allowed_keys_in_payload(keys = [])
        @extra_keys_in_payload = keys
      end

      def trigger(user:, subject:, source:, payload: {}, request_info: {}, source_component: nil, delay: nil)
        validate_subject(subject)

        job = if delay.is_a? ActiveSupport::Duration
                set(wait: delay)
              else
                self
              end

        job.perform_later(
          name: @event_name || name.demodulize.underscore.dasherize,
          subject: subject,
          user: user,
          payload: normalize_payload(payload.merge(request_info)),
          # Note(Dhruv): ActiveJob doesn't support serializing symbols, converting
          # to integer explicitly here for now
          source: Stream::Event.sources[source],
          source_component: source_component,
          source_path: request_info[:referer] || nil,
          received_at: Time.zone.now.to_i,
        )
      end

      def fanout_workers(&block)
        define_method(:fetch_fanout_workers, &block)
      end

      def should_fanout(&block)
        define_method(:run_should_fanout_block_as_method, &block)
        define_method :should_fanout do |*args|
          run_should_fanout_block_as_method(*args)
        rescue ActiveRecord::RecordNotFound
          false
        end
      end

      private

      def validate_subject(subject)
        allowed = @allowed_subjects.any? { |x| subject.is_a? x }
        raise ::Stream::Errors::Events::InvalidSubject unless allowed
      end
    end
  end
end
