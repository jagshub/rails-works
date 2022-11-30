# frozen_string_literal: true

class HouseKeeper::MaintainWorker
  include Sidekiq::Worker

  sidekiq_options retry: 0
  sidekiq_options backtrace: true

  def perform(product_link_ids)
    HouseKeeper::Maintain.batch(
      LegacyProductLink.where(id: product_link_ids).includes(:product, :user),
    )
  end
end
