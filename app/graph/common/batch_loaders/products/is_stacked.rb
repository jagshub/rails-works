# frozen_string_literal: true

module Graph::Common::BatchLoaders
  class Products::IsStacked < GraphQL::Batch::Loader
    def initialize(user)
      @user = user
    end

    def perform(products)
      return false unless @user

      stacked_product_ids = ::Products::Stack.where(user: @user).pluck(:product_id)

      products.each do |product|
        fulfill product, stacked_product_ids.include?(product.id)
      end
    end
  end
end
