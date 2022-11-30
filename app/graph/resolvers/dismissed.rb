# frozen_string_literal: true

class Graph::Resolvers::Dismissed < Graph::Resolvers::Base
  argument :dismissable_key, String, required: false
  argument :dismissable_group, String, required: false

  type Graph::Types::DismissType, null: true

  def resolve(dismissable_key: nil, dismissable_group: nil)
    DismissContent.dismissed(
      cookies: context[:cookies],
      dismissable_key: dismissable_key,
      dismissable_group: dismissable_group,
      user: current_user,
    )
  end
end
