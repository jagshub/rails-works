module Types
  class BaseField < GraphQL::Schema::Field
    def resolve_field(obj, args, ctx)
      Rails.logger.info "BaseField!!"
      resolve(obj, args, ctx)
    end
  end
end
