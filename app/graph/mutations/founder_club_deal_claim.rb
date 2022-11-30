# frozen_string_literal: true

module Graph::Mutations
  class FounderClubDealClaim < BaseMutation
    argument_record :deal, ::FounderClub::Deal, required: true, authorize: :claim

    class FounderClubRedemptionCode < Graph::Types::BaseObject
      field :code, String, null: false
      field :redemption_url, String, null: true
      field :how_to_claim, String, null: false
      field :deal, Graph::Types::FounderClubDealType, null: false

      def code
        object.redemption_code.code
      end

      def redemption_url
        return unless object.deal.redemption_url

        object.deal.redemption_url.gsub('[code]', code)
      end

      def how_to_claim
        object.deal.how_to_claim
      end
    end

    returns FounderClubRedemptionCode

    def perform(deal:)
      claim = FounderClub.claim_deal(user: current_user, deal: deal)
      claim || error(:base, :cant_redeem_deal)
    end
  end
end
