# frozen_string_literal: true

class Users::UpdateRole
  class << self
    def call(user:, suggested_role:)
      new(user: user, suggested_role: suggested_role).call
    end
  end

  def initialize(user:, suggested_role:)
    @user           = user
    @suggested_role = suggested_role
  end

  def call
    @user.update! role: @suggested_role if better_role?
  end

  private

  def better_role?
    Users::BetterRole.call(old_role: @user.role, new_role: @suggested_role)
  end
end
