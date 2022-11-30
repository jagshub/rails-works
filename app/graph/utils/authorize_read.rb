# frozen_string_literal: true

# NOTE(vlad): Use extend Graph::Utils::AuthorizeRead
# Works only with base object
module Graph::Utils::AuthorizeRead
  def authorized?(object, context)
    super && (object.nil? || ApplicationPolicy.can?(context[:current_user], ApplicationPolicy::READ, object))
  end
end
