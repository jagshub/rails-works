# frozen_string_literal: true

class Graph::Resolvers::Comments::Commentable < Graph::Resolvers::Base
  type Graph::Types::CommentableInterfaceType, null: true

  argument :type, String, required: true
  argument :id, ID, required: true

  TYPES = Comment::SUBJECT_TYPES.map(&:constantize).inject({}) do |acc, record_class|
    begin
      acc[Graph::Utils::ResolveType.from_class(record_class).graphql_name] = record_class
    rescue Graph::Utils::ResolveType::UnknownTypeError
      # NOTE(rstankov): Ignore types, not exposed to GraphQL
      nil
    end
    acc
  end

  def resolve(id:, type:)
    klass = TYPES[type]

    return if klass.blank?

    record = klass.find_by id: id

    return if record.blank?
    return if record.respond_to?(:trashed?) && record.trashed?

    record
  end
end
