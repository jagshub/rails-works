# frozen_string_literal: true

module Authorization
  def authorize!(action, subject)
    ApplicationPolicy.authorize!(current_user, action, subject)
  end

  def can?(action, subject)
    ApplicationPolicy.can?(current_user, action, subject)
  end
end
