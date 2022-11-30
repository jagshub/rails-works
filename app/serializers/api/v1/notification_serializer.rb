# frozen_string_literal: true

class API::V1::NotificationSerializer < API::V1::BaseSerializer
  delegated_attributes(
    :body,
    :id,
    :seen,
    :sentence,
    to: :resource,
  )

  attributes(
    :type,
    :reference,
    :from_user,
    :created_at,
    :to_user,
  )

  def type
    serialize_class_name resource.reference.class.name
  end

  def reference
    serialize_basic_resource resource.reference
  end

  def from_user
    serialize_basic_resource resource.from_user
  end

  def to_user
    {}
  end

  def created_at
    resource.timestamp
  end
end
