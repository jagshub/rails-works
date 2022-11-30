# frozen_string_literal: true

class Cron::HouseKeeping::MaintainWorker < ApplicationJob
  def perform
    # NOTE(DZ): For now, manually run until we backfill existing posts that
    # need to be notified (2 years ago from this comment date feb 22, 2021)

    # LegacyProductLink
    #   .joins(:product)
    #   .not_broken
    #   .where.not(products: { state: LegacyProduct.states[:no_longer_online] })
    #   .find_in_batches do |product_links|
    #   HouseKeeper::MaintainWorker.perform_async(product_links.map(&:id))
    # end
  end
end
