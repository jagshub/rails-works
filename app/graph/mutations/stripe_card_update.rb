# frozen_string_literal: true

module Graph::Mutations
  class StripeCardUpdate < BaseMutation
    argument :stripe_token_id, String, required: true
    argument :project_type, String, required: true

    require_current_user

    def perform(stripe_token_id:, project_type:)
      subscription = current_user.payment_subscriptions.find_by(project: project_type)

      return error :subscription, 'subscription not found' if subscription.nil?
      return error :token, 'invalid stripe token' unless stripe_token_id.start_with?('tok_')

      update_card(subscription, stripe_token_id, project_type)

      nil
    end

    private

    def update_card(subscription, stripe_token_id, project_type)
      External::StripeApi.delete_card(subscription.stripe_customer_id, External::StripeApi.fetch_customer_card(subscription.stripe_customer_id).id)
      External::StripeApi.create_card(subscription.stripe_customer_id, stripe_token_id)
      Payment::CardUpdateLog.create!(stripe_token_id: stripe_token_id, user_id: current_user.id, stripe_customer_id: subscription.stripe_customer_id, project: project_type)
    rescue Stripe::StripeError => e
      Payment::CardUpdateLog.create!(stripe_token_id: stripe_token_id, user_id: current_user.id, stripe_customer_id: subscription.stripe_customer_id, success: false, project: project_type)
      ErrorReporting.report_error(e, extra: { user_id: current_user.id, subscription_id: subscription.id })
    end
  end
end
