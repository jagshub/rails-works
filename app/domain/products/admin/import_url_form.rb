# frozen_string_literal: true

class Products::Admin::ImportUrlForm < Admin::BaseForm
  model :product, attributes: %i(name website_url clean_url tagline), save: true

  main_model :product, Product

  validates :website_url, presence: true
  validates :name, presence: true
  validates :tagline, presence: true
  validate :ensure_clean_url_is_unique

  after_update :schedule_scraper

  def initialize
    @product = Product.admin.new
  end

  def website_url=(url)
    product.website_url = url
    product.clean_url = UrlParser.clean_product_url(url)
  end

  private

  def ensure_clean_url_is_unique
    product = Product.find_by(clean_url: clean_url)
    return if product.blank?

    errors.add(
      :website_url, "already belongs to #{ Routes.admin_product_url(product) }"
    )
  end

  def schedule_scraper
    Products::Scrapers.schedule(product: product)
  end
end
