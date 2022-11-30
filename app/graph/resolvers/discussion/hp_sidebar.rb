# frozen_string_literal: true

module Graph::Resolvers
  class Discussion::HpSidebar < Graph::Resolvers::Base
    type [Graph::Types::Discussion::ThreadType], null: false

    def resolve
      scope = object.discussions
      featured = scope.featured
                      .where(::Discussion::Thread.arel_table[:featured_at].lteq(Time.current))
                      .order(featured_at: :desc, id: :desc)
                      .limit(1)
      scope = scope.visible
                   .where(::Discussion::Thread.arel_table[:trending_at].gt(1.week.ago))
                   .where(::Discussion::Thread.arel_table[:trending_at].lteq(Time.current))
                   .order(trending_at: :desc)
      return scope.limit(5) if featured.blank?

      top_discussions = scope.where.not(id: featured.first.id).limit(4)

      featured + top_discussions
    end
  end
end
