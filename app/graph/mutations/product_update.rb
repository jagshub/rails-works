# frozen_string_literal: true

module Graph::Mutations
  class ProductUpdate < BaseMutation
    argument_record :product, Product, authorize: :edit

    argument :name, String, required: true
    argument :tagline, String, required: true
    argument :media, [Graph::Types::MediaRecordInputType], required: true
    argument :logo_uuid, String, required: false
    argument :description, String, required: false
    argument :twitter_url, String, required: false

    returns Graph::Types::ProductType

    require_current_user

    def perform(product:, **params)
      form = Products::UpdateForm.new(product, user: current_user)
      form.update params

      form
    end
  end
end
