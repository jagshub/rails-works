# frozen_string_literal: true

module Graph::Resolvers
  class UpcomingPages::DemographicsMetricsResolver < Graph::Resolvers::Base
    class TYPE < Graph::Types::BaseObject
      graphql_name 'UpcomingPageDemographicMetrics'

      field :count, Int, null: false
      field :country_name, String, null: false
      field :country_code, String, null: false
      field :emoji, String, null: false
    end

    type [TYPE], null: false

    def resolve
      page = object
      return [] unless ApplicationPolicy.can?(current_user, ApplicationPolicy::MAINTAIN, page)

      stats_for(page).map do |(count, geo_country)|
        DemographicsMetrics.new(
          country_name: geo_country,
          count: count,
        )
      end.select(&:valid?)
    end

    private

    def stats_for(page)
      Rails.cache.fetch("upcoming_page_demographics/#{ page.id }", expires_in: 1.day) do
        page
          .subscribers
          .confirmed
          .joins(contact: :clearbit_person_profile)
          .where.not('clearbit_person_profiles.geo_country' => nil)
          .group(:geo_country)
          .pluck(Arel.sql('count(*)'), :geo_country)
      end
    end

    class DemographicsMetrics
      attr_reader :count

      def initialize(country_name:, count:)
        @count = count
        @country = ISO3166::Country.find_country_by_name(country_name)
      end

      def country_name
        @country.unofficial_names.first || @country.name
      end

      def country_code
        @country.un_locode
      end

      def emoji
        @country.emoji_flag
      end

      def valid?
        @country.present? && @country.ioc.present?
      end
    end
  end
end
