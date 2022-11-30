# frozen_string_literal: true

module Products::Scrapers
  class Jobs::JSON
    include Sidekiq::Worker

    sidekiq_options retry: 0
    sidekiq_options backtrace: true

    def perform(params)
      product = Product.find(params['product_id'])
      Products::Scrapers.json(product: product)
    end
  end
end
