# frozen_string_literal: true

module Graph::Mutations
  class JobPurchase < BaseMutation
    argument :stripe_token_id, String, required: true
    argument :billing_email, String, required: true
    argument :extra_packages, [String], required: false
    argument :feature_homepage, Boolean, required: true
    argument :feature_job_digest, Boolean, required: true
    argument :plan_id, ID, required: true
    argument :job_id, String, required: true
    argument :extra, Graph::Types::PaymentExtraInputType, required: false

    returns Graph::Types::JobType

    def perform(inputs)
      ::Payments::HandleError.call(current_user_id: current_user&.id) do
        Jobs::Purchase.call(
          user: current_user,
          inputs: inputs,
          job: Job.friendly.find(inputs[:job_id]),
          plan: Jobs::Plans.find_by_id(inputs[:plan_id]),
          request_info: request_info,
        )
      end
    end
  end
end
