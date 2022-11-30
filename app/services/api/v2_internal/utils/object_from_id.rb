# frozen_string_literal: true

module API::V2Internal::Utils::ObjectFromId
  extend self

  def call(id, ctx = {})
    return if id.blank?

    record = find id
    return if record.blank?
    return if record.respond_to?(:trashed?) && record.trashed? && !ctx[:current_user]&.admin?

    unless implements_node_interface?(record)
      ErrorReporting.report_warning_message("Try to access restricted record - '#{ record.class.name }:#{ record.id }'")
      raise 'Record does not implement node interface. Check if you need to add \'graphql_type\'' unless Rails.env.production?

      return
    end

    record
  end

  private

  def find(id)
    record_class_name, record_id = decode(id)

    return if record_class_name.blank?
    return if record_id.blank?

    record_class = record_class_name.safe_constantize
    record_class&.find_by id: record_id
  end

  def implements_node_interface?(record)
    type = API::V2Internal::Utils::ResolveType.from_class(record.class)
    type.interfaces.include? GraphQL::Types::Relay::Node
  rescue API::V2Internal::Utils::ResolveType::UnknownTypeError
    false
  end

  def decode(id)
    GraphQL::Schema::UniqueWithinType.decode(id)
  rescue ArgumentError
    [nil, nil]
  end
end
