# frozen_string_literal: true

module Graph::Types
  class PaymentInvoiceInputType < BaseInputObject
    argument :company_name, String, required: false
  end
end
