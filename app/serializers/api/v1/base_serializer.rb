# frozen_string_literal: true

class API::V1::BaseSerializer < BaseSerializer
  self.root = true

  private

  def serialize_class_name(class_name)
    class_name
  end

  BASIC_MAPPING = {
    'Collection' => 'BasicCollectionSerializer',
    'Comment' => 'BasicCommentSerializer',
    'Post' => 'BasicPostSerializer',
    'User' => 'BasicUserSerializer',
  }.freeze

  def serialize_basic_resource(object)
    serializer = BASIC_MAPPING[object.class.name]
    return unless serializer

    "::API::V1::#{ serializer }".safe_constantize.new object, root: false, scope: scope
  end

  def exclude?(item)
    scope[:exclude]&.include?(item)
  end

  def include?(item)
    scope[:include]&.include?(item)
  end
end
