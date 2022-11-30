# frozen_string_literal: true

class API::Widgets::Upcoming::V1::UpcomingSerializer < BaseSerializer
  self.root = true

  delegated_attributes(
    :id,
    :widget_intro_message,
    to: :resource,
  )

  attributes(
    :user_avatar_url,
    :embed_url,
  )

  def user_avatar_url
    Users::Avatar.url_for_user(resource.user, size: 120)
  end

  def embed_url
    # NOTE(rstankov): Full path includes wrong port during development
    if Rails.env.development?
      Routes.upcoming_widgets_v1_path(resource)
    else
      Routes.upcoming_widgets_v1_url(resource)
    end
  end
end
