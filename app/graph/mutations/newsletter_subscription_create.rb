# frozen_string_literal: true

module Graph::Mutations
  class NewsletterSubscriptionCreate < BaseMutation
    argument :email, String, required: true
    argument :status, String, required: true
    argument :source, String, required: false

    returns Graph::Types::ViewerType

    def perform(inputs)
      HandleRaceCondition.call do
        form = Newsletter::SubscribeForm.new(user: current_user)
        form.update! inputs

        current_user
      end
    end
  end
end
