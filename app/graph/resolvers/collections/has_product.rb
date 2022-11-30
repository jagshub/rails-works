# frozen_string_literal: true

class Graph::Resolvers::Collections::HasProduct < Graph::Resolvers::Base
  argument :product_id, ID, required: true

  type Boolean, null: false

  def resolve(product_id)
    return false if current_user.blank?

    Graph::Common::BatchLoaders::Collections::HasProduct
      .for(product_id)
      .load(object)
  end
end
