# frozen_string_literal: true

module Graph::Resolvers
  class UpcomingPages::VariantResolver < Graph::Resolvers::Base
    argument :preferred_kind, String, required: false

    type Graph::Types::UpcomingPageVariantType, null: false

    def resolve(preferred_kind: nil)
      preferred_kind(object, context[:cookies], preferred_kind) || object.default_variant || new_variant_for(object)
    end

    private

    def preferred_kind(upcoming_page, cookies, kind)
      return unless kind

      kind = random_variant(upcoming_page, cookies) if kind == 'random'

      upcoming_page.variant(kind)
    end

    def random_variant(upcoming_page, cookies)
      cookies[:upcoming_ab_seed] ||= Random.new_seed

      random = Random.new(cookies[:upcoming_ab_seed].to_i + upcoming_page.id)
      UpcomingPageVariant.kinds.keys.sample(random: random)
    end

    def new_variant_for(upcoming_page)
      upcoming_page.variants.new kind: :a
    end
  end
end
