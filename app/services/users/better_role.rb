# frozen_string_literal: true

module Users
  module BetterRole
    extend self

    WORST_TO_BEST_ROLE = %i(
      spammer
      potential_spammer
      bad_actor
      company
      user
      can_post
      external_moderator
      admin
    ).freeze

    # Determines if the new role is "better" than the old role (i.e. gives more access to the site)
    def call(old_role:, new_role:)
      old_role_index = WORST_TO_BEST_ROLE.index(old_role.try(:to_sym))
      new_role_index = WORST_TO_BEST_ROLE.index(new_role.try(:to_sym))

      return false if old_role_index.nil? || new_role_index.nil?

      new_role_index > old_role_index
    end
  end
end
