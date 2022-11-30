# frozen_string_literal: true

class UpcomingEvents::Form
  include MiniForm::Model

  model :upcoming_event, save: true, attributes: %i(
    title
    description
    banner_uuid
    banner_mobile_uuid
    user_edited_at
  )

  attributes :user

  alias graphql_result upcoming_event

  class << self
    def create(post:, user:, **params)
      upcoming_event = Upcoming::Event.new(
        post: post,
        user: user,
        product: post&.new_product,
      )

      form = new(upcoming_event: upcoming_event, user: user)
      form.update(**params)
      form
    end

    def update(upcoming_event:, user:, **params)
      form = new(upcoming_event: upcoming_event, user: user)
      form.update(**params)
      form
    end
  end

  def initialize(upcoming_event:, user:)
    @upcoming_event = upcoming_event
    @user = user
  end

  def update(**params)
    Audited.audit_class.as_user(user) do
      super(**params)
    end
  end
end
