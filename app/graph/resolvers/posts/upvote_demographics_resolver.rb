# frozen_string_literal: true

module Graph::Resolvers
  class Posts::UpvoteDemographicsResolver < Graph::Resolvers::Base
    class DemographicsType < Graph::Types::BaseObject
      graphql_name 'PostUpvoteDemographics'

      field :count, Int, null: false
      field :country_name, String, null: false
      field :country_code, String, null: false
      field :emoji, String, null: false
    end

    type [DemographicsType], null: false

    LAUNCH_DAY_POST_ID = 161_010

    def resolve
      if object.id == LAUNCH_DAY_POST_ID ||
         ApplicationPolicy.can?(current_user, :maintain, object)

        stats_for(object)
      else
        []
      end
    end

    private

    def stats_for(post)
      Rails.cache.fetch(cache_key(post), expires_in: expiration(post)) do
        votes_count =
          post.votes.joins(:user).credible.group('users.country').count

        stats = votes_count.map do |(country_name, count)|
          DemographicsMetrics.new(
            country_name: country_name,
            count: count,
          )
        end

        stats = stats.select(&:valid?).sort { |a, b| b.count <=> a.count }

        if votes_count[nil].present?
          stats << {
            country_name: 'Private',
            country_code: '',
            count: votes_count[nil],
            emoji: '🔒',
          }
        end

        stats
      end
    end

    def cache_key(post)
      "post_upvote_demographics/#{ post.id }"
    end

    HOURLY_BREAKPOINT = 1.week

    def expiration(post)
      time = post.scheduled_at || post.created_at
      if time <= HOURLY_BREAKPOINT.ago
        1.day
      else
        1.hour
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
        @country.present? && @country.un_locode.present?
      end
    end
  end
end
