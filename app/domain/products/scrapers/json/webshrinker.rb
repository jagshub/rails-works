# frozen_string_literal: true

module Products::Scrapers::JSON
  class Webshrinker < Base
    invoke do |product|
      api_response = External::APIResponse.fetch(
        params: { website_url: product.website_url },
        kind: :webshrinker,
      ) do
        External::WebshrinkerAPI.categories(product.website_url)
      end

      api_response.response
    end

    field :categories do
      category_data = response.dig('data', 0, 'categories')
      return [] if category_data.blank?

      # NOTE(DZ): Only collect "confident" => true categories
      category_data
        .select { |category| category['confident'] }
        .map { |category| category['label'] }
    end
  end
end
