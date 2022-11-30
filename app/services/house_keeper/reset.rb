# frozen_string_literal: true

module HouseKeeper::Reset
  extend self

  def product_link(product_link)
    product_link.update!(broken: false)
    HouseKeeperBrokenLink.where(product_link: product_link).destroy_all
  end
end
