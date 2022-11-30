# frozen_string_literal: true

module FounderClub::ClaimDeal
  extend self

  class CantRedeemDealError < StandardError
  end

  def call(user:, deal:)
    raise CantRedeemDealError, "Deal ##{ deal.id } isnt active" unless deal.active?

    claim = ::FounderClub::Claim.find_by(user: user, deal: deal)

    return claim if claim

    redemption_code = find_redemption_code(deal)

    if redemption_code.nil?
      FounderClubMailer.deal_redemption_codes_exhausted(deal).deliver_later
      raise CantRedeemDealError, "Deal ##{ deal.id } doesnt have any #{ deal.redemption_method } codes."
    end

    ::FounderClub::Claim.create!(
      deal: deal,
      user: user,
      redemption_code: redemption_code,
    )
  end

  private

  def find_redemption_code(deal)
    if deal.unlimited?
      deal.redemption_codes.unlimited.first
    else
      deal.redemption_codes.within_limit.first
    end
  end
end
