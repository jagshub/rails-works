module Types
  class BaseObject < GraphQL::Schema::Object
    field_class PreloadableField
  end
end
