# frozen_string_literal: true

module Graph::Types
  class JobBoardType < BaseObject
    field :jobs_count, Integer, null: false
    field :available_locations, [String], null: false
    field :available_categories, [String], null: false
    field :is_subscribed, Boolean, null: false

    field :jobs, Graph::Types::JobType.connection_type, null: false, connection: true

    def jobs_count
      object.count
    end

    def available_locations
      fetch('locations')
    end

    def available_categories
      fetch('categories')
    end

    def is_subscribed
      return false unless context.current_user

      context.current_user.subscriber.jobs_newsletter_subscription == Jobs::Newsletter::Subscriptions::SUBSCRIBED
    end

    def jobs
      object
    end

    private

    def fetch(name)
      @data ||= object.pluck(:data)
      @data.map { |x| x[name] }.flatten.uniq.compact.sort
    end
  end
end
