# frozen_string_literal: true

module Moderation::Policy
  extend KittyPolicy
  extend self

  can :edit, Moderation::DuplicatePostRequest do |user|
    admin?(user)
  end

  private

  def admin?(user)
    user&.admin?
  end
end
