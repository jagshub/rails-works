# frozen_string_literal: true

module Graph::Types
  class PaymentAddressInputType < BaseInputObject
    argument :line1, String, required: false
    argument :line2, String, required: false
    argument :city, String, required: false
    argument :state, String, required: false
    argument :postal_code, String, required: false
    argument :country, String, required: false
  end
end
