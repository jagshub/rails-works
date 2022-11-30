# frozen_string_literal: true

module Products::Scrapers
  class Jobs::HTML
    include Sidekiq::Worker

    sidekiq_options retry: 0
    sidekiq_options backtrace: true

    def perform(params)
      product = Product.find(params['product_id'])
      Products::Scrapers.html(product: product, url: params['url'])
    end
  end
end
