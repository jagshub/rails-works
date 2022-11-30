# frozen_string_literal: true

module Graph::Mutations
  class ShoutoutCreate < BaseMutation
    argument :body, String, required: false

    returns Graph::Types::ShoutoutType

    authorize :create, Shoutout

    def perform(body: nil)
      shoutout = Shoutout.create(user: current_user, body: body)

      after_create(shoutout) if shoutout.persisted?

      shoutout
    end

    private

    def after_create(shoutout)
      create_notifications(shoutout)
    end

    def create_notifications(shoutout)
      Notifications.notify_about(kind: 'shoutout_mention', object: shoutout)
    end
  end
end
