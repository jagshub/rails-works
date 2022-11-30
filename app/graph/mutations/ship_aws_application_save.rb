# frozen_string_literal: true

module Graph::Mutations
  class ShipAwsApplicationSave < BaseMutation
    argument_record :ship_account, ShipAccount, required: true, authorize: ApplicationPolicy::MAINTAIN
    argument :startup_name, String, required: false
    argument :startup_email, String, required: false

    def perform(ship_account:, startup_name: nil, startup_email: nil)
      application = ShipAwsApplication.find_or_initialize_by(ship_account: ship_account).tap do |app|
        app.startup_name = startup_name
        app.startup_email = startup_email
        app.save
      end

      application if application.errors.any?
    end
  end
end
