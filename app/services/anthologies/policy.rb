# frozen_string_literal: true

module Anthologies::Policy
  extend KittyPolicy
  extend self

  can :create, Anthologies::Story do |user| # rubocop:disable Style/SymbolProc
    user.admin?
  end

  can :update, Anthologies::Story do |user, _story|
    # NOTE(rstankov): We didn't allow authors to edit their stories
    user.admin?
  end

  can :read, Anthologies::Story, allow_guest: true do |user, story|
    if story.published?
      true
    elsif user.present?
      user.admin? || user.id == story.user_id
    else
      false
    end
  end
end
