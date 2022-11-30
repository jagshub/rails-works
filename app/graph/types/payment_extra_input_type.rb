# frozen_string_literal: true

module Graph::Types
  class PaymentExtraInputType < BaseInputObject
    argument :name, String, required: false
    argument :phone, String, required: false
    argument :address, Graph::Types::PaymentAddressInputType, required: false
    argument :payment_method_id, String, required: false
    argument :invoice, [Graph::Types::PaymentInvoiceInputType], required: false
  end
end
