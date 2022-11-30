# frozen_string_literal: true

class API::Widgets::Cards::V1::CommentSerializer < BaseSerializer
  self.root = true

  delegated_attributes(
    :id,
    :created_at,
    to: :resource,
  )

  attributes(
    :body_html,
    :subject,
    :url,
    :user,
  )

  def body_html
    BetterFormatter.call(resource.body, mode: :full)
  end

  def user
    API::Widgets::Cards::V1::UserSerializer.resource(resource.user)
  end

  def subject
    {
      id: resource.subject_id,
      name: resource.subject_name,
      type: resource.subject_type,
    }
  end

  def url
    api_widgets_cards_redirect_url(::Cards.id_for(resource))
  end
end
