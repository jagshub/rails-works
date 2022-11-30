# frozen_string_literal: true

module RouteConstraints
  class Admin
    def matches?(request)
      return false if request.session[:user_id].blank?

      user = User.visible.find_by(id: request.session[:user_id])
      return false if user.blank?

      user.admin?
    end
  end
end
