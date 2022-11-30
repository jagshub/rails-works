# frozen_string_literal: true

class Graph::Resolvers::UpcomingPages::UserPagesResolver < Graph::Resolvers::Base
  type [Graph::Types::UpcomingPageType], null: false

  def resolve
    if object == :viewer
      if context[:current_user]
        UpcomingPage.not_trashed.for_maintainers(context[:current_user]).order('id DESC')
      else
        []
      end
    else
      UpcomingPage.not_trashed.for_maintainers(object).order('id DESC')
    end
  end
end
