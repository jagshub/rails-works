# frozen_string_literal: true

module UserBadges
  extend self

  AWARDS = {
    'thought_leader' => UserBadges::Badge::ThoughtLeader,
    'contributor' => UserBadges::Badge::Contributor,
    'buddy_system' => UserBadges::Badge::BuddySystem,
    'gemologist' => UserBadges::Badge::Gemologist,
    'in_real_life' => UserBadges::Badge::InRealLife,
    'maker_grant_recipient' => UserBadges::Badge::MakerGrantRecipient,
    'veteran' => UserBadges::Badge::Veteran,
    'top_product' => UserBadges::Badge::TopProduct,
    'beta_tester' => UserBadges::Badge::BetaTester,
  }.freeze

  def award_for(identifier:)
    AWARDS.fetch(identifier)
  end

  def badge_active?(identifier:)
    Badges::Award.exists?(identifier: identifier, active: true)
  end

  def thought_leader_worker
    UserBadges::Workers::ThoughtLeaderWorker
  end

  def contributor_worker
    UserBadges::Workers::ContributorWorker
  end

  def buddy_system_worker
    UserBadges::Workers::BuddySystemWorker
  end

  def gemologist_worker
    UserBadges::Workers::GemologistWorker
  end

  def gemologist_progress_worker
    UserBadges::Workers::GemologistProgressWorker
  end

  def veteran_worker
    UserBadges::Workers::VeteranWorker
  end

  def top_product_worker
    UserBadges::Workers::TopProductWorker
  end
end
