# frozen_string_literal: true

module Graph::Resolvers
  class Products::IsStackedResolver < Graph::Resolvers::Base
    type Boolean, null: false

    def resolve
      return false if current_user.blank?

      Graph::Common::BatchLoaders::Products::IsStacked.for(current_user).load(object)
    end
  end
end
