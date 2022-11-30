# frozen_string_literal: true

class Graph::Mutations::UserCookiePolicyAccept < Graph::Mutations::BaseMutation
  argument :agreed, Boolean, required: true

  returns Graph::Types::ViewerType

  def perform
    CookiePolicy.accept(
      cookies: context[:cookies],
      ip: context[:request].remote_ip,
      user: current_user,
    )

    :viewer
  end
end
