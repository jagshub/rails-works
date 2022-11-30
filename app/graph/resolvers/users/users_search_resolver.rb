# frozen_string_literal: true

class Graph::Resolvers::Users::UsersSearchResolver < Graph::Resolvers::Base
  argument :query, String, required: true

  def resolve(query:)
    scope = User.visible.non_spammer

    # Note(AR): if the query doesn't have any word characters, it's effectively empty
    if query.present? && query =~ /\w/
      # (nvalchanov): This uses gin index. Any change in this query should also change the index.
      scope = scope.where('username LIKE :query OR name ILIKE :query', query: LikeMatch.by_words(query))
      scope = scope.order_by_friends(current_user) if current_user.present?
    elsif current_user
      # NOTE(rstankov): When we search for all just show friends
      scope = current_user.friends.visible.non_spammer
    end

    scope
  end
end
