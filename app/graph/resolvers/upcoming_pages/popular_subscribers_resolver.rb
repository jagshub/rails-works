# frozen_string_literal: true

module Graph::Resolvers
  class UpcomingPages::PopularSubscribersResolver < Graph::Resolvers::Base
    type [Graph::Types::UserType], null: false

    def resolve
      key = get_cache_key(object.id, object.subscriber_count, current_user&.id)

      user_ids = Rails.cache.fetch(key, expires_in: 1.hour) do
        FamiliarUsers.call(
          user_scope: object.users,
          current_user: current_user,
          count: 3,
          exclude_ids: [object.user_id],
        ).group_by.pluck(:id)
      end

      User.where(id: user_ids)
    end

    private

    def get_cache_key(id, count, user_id = nil)
      "upcoming_pages_popular_subscribers:#{ id }-#{ user_id }-#{ count < 3 ? count : 'cached' }"
    end
  end
end
