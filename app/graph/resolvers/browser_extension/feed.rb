# frozen_string_literal: true

class Graph::Resolvers::BrowserExtension::Feed < Graph::Resolvers::Base
  type Graph::Types::BrowserExtension::FeedPage.connection_type, null: false

  def resolve
    Resolver.new
  end

  class Resolver
    def [](cursor)
      Page.new(days_ago: cursor)
    end

    def last_index
      @last_index ||= calculate_last_index
    end

    private

    FIRST_POST_DATE = Date.new(2013, 11, 27)

    def calculate_last_index
      # NOTE(rstankov): In production/development is expensive to make extra query
      #   to have the real date of the oldest post
      if Rails.env.test?
        first_post_date = Post.minimum(:created_at)&.in_time_zone&.to_date
        (Time.zone.today - (first_post_date || Time.zone.today)).to_i
      else
        (Time.zone.today - FIRST_POST_DATE).to_i
      end
    end
  end

  class Page
    attr_reader :days_ago, :cutoff_index

    alias cursor days_ago

    def initialize(days_ago:)
      @days_ago = days_ago

      cutoff = days_ago.zero? ? 11 : 12

      @cutoff_index = days_ago < 2 ? [::Feed.posts_with_rank_count(Rails.configuration.settings.rank_floor.to_f, days_ago: days_ago), cutoff].max : cutoff
    end

    def id
      # NOTE(rstankov): Apollo requires each section to have unique id
      #   Otherwise doesn't overwrite section data
      Base64.encode64(days_ago.to_s)
    end

    def date
      @date ||= days_ago.days.ago.to_datetime
    end

    def posts_count
      @posts_count ||= ::Feed.posts_count(days_ago: days_ago)
    end

    def posts
      @posts ||= ::Feed.posts(days_ago: days_ago)
    end

    def ==(other)
      other.class == self.class && other.id == id
    end
  end

  class Connection < GraphQL::Pagination::Connection
    def total_count
      items.last_index
    end

    def cursor_for(item)
      encode(item.cursor.to_s)
    end

    def nodes
      Array.new(limit) { |i| items[offset + i] }
    end

    def has_next_page
      return false if first_value.blank?

      offset + limit + 1 <= items.last_index
    end

    def has_previous_page
      return false if last_value.blank?

      offset - 1 >= 0
    end

    private

    def index_from_cursor(cursor)
      decode(cursor).to_i
    end

    def offset
      @offset ||= if last_value
                    before_value ? index_from_cursor(before_value) - limit : items.last_index + 1 - limit
                  elsif first_value
                    after_value ? index_from_cursor(after_value) + 1 : 0
                  else
                    raise 'Missing before or after'
                  end
    end

    def limit
      @limit ||= if last_value
                   [[0, last_value].max, max_page_size || 1].min
                 elsif first_value
                   [[0, first_value].max, max_page_size || 1].min
                 else
                   raise 'Missing before or after'
                 end
    end
  end
end
