# frozen_string_literal: true

module Graph::Utils
  class ReportingExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, arguments:, **rest)
      context = rest[:context]

      Marginalia::Comment.marginalia_extra = context[:current_path]

      ErrorReporting.set_graphql_path(context[:current_path])

      yield(object, arguments, context, rest)
    end
  end
end
