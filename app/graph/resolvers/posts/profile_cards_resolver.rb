# frozen_string_literal: true

class Graph::Resolvers::Posts::ProfileCardsResolver < Graph::Resolvers::Base
  type [Graph::Types::PostType], null: false

  def resolve
    return [] if current_user.blank? || (current_user.id != object.id && !current_user.admin?)

    made_and_hunted_products = (object.product_ids + object.post_ids).uniq

    return [] if made_and_hunted_products.empty?

    start_date = (Time.zone.now - 1.day).beginning_of_day

    scope = Post.where(id: made_and_hunted_products).not_trashed
    # Note(Rahul): The posts are sorted in a way that today's featured post shows up
    #              first then old(1 day older) & scheduled (future) posts
    scope
      .where_time_gteq(:featured_at, start_date)
      .or(scope.where_time_gteq(:scheduled_at, start_date))
      .order(
        Arel.sql('(case when DATE(COALESCE(featured_at, scheduled_at, created_at)) = CURRENT_DATE then 1 else 0 end) desc'),
        { featured_at: :asc },
        scheduled_at: :asc,
      )
      .limit(5)
  end
end
