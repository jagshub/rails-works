# frozen_string_literal: true

module MakersFestival::Policy
  extend KittyPolicy
  extend self

  can :create_discussion, MakersFestival::Edition do |user, edition|
    discussion_maintainers_for_edition = ::MakersFestival::Utils::DISCUSSION_MAINTAINERS[edition.slug] || []
    edition.participant?(user) || user.admin? || discussion_maintainers_for_edition.include?(user.id.to_s)
  end

  can :update_participant, MakersFestival::Participant do |user, participant|
    user.id == participant.user_id
  end
end
