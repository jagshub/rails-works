# frozen_string_literal: true

# NOTE(vlad): Use extend Graph::Utils::AuthorizeMantain
# Works only with base object
module Graph::Utils::AuthorizeMantain
  def authorized?(object, context)
    super && (object.nil? || ApplicationPolicy.can?(context[:current_user], ApplicationPolicy::MAINTAIN, object))
  end
end
