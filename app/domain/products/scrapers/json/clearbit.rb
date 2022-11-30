# frozen_string_literal: true

module Products::Scrapers::JSON
  class Clearbit < Base
    invoke do |product|
      api_response = External::APIResponse.fetch(
        params: { website_url: product.website_url },
        kind: :clearbit_company,
      ) do
        External::ClearbitAPI.company(product.website_url)
      end

      api_response.response
    end

    field :description do
      response['description']
    end
  end
end
