# frozen_string_literal: true

# NOTE(Raj): Used to create products with serp api + meta scraper.
#            For an existing product, updates blank product fields w/ data from serp api.
#            We should be mindful of serp api credits before using this on bulk actions.
module Products::SetWithGoogleScraper
  extend self

  # NOTE(Raj): Documentation - https://dashboard.clearbit.com/docs?ruby#logo-api
  CLEARBIT_LOGO_API_URL = 'https://logo.clearbit.com/'

  def call(product_name:)
    return if product_name.blank?

    search_result = External::SerpApi.find_product_for_scraper(
      product_name: product_name,
    )

    return if search_result.blank?

    product_clean_url = UrlParser.clean_product_url(search_result[:website_url])

    return if search_result[:website_url].nil? || product_clean_url.nil?

    product = Product.find_by(clean_url: product_clean_url)

    # NOTE(Raj): we already have a product, so enrich blank data.
    if product.present?
      product.description ||= search_result[:description]
      product.twitter_url ||= search_result[:twitter_url]
      product.facebook_url ||= search_result[:facebook_url]
      product.instagram_url ||= search_result[:instagram_url]

      # NOTE(Raj): save the scraped data from serp/google for any future use.
      save_scrape_results(product, 'serp_api' => search_result)

      product.save! if product.changed?

      return product
    end

    meta_scraper = Products::Scrapers::HTML::Meta.new(search_result[:website_url])

    # NOTE(Raj): If product websites blocks scraping/returns a cf anti-bot page, we return.
    return if meta_scraper.response.blank? || meta_scraper.response.code != 200

    meta_scrape_result = meta_scraper.to_h

    image_url = meta_scrape_result[:logos].compact_blank.uniq.first
    image_url ||= "#{ CLEARBIT_LOGO_API_URL }#{ product_clean_url }"
    logo_from_scraper_or_clearbit = upload_logo(image_url)

    logo = logo_from_scraper_or_clearbit.presence || upload_logo(search_result[:logo])
    extracted_attrs = extract_attrs_from_tagline(meta_scrape_result[:tagline], product_name)

    ActiveRecord::Base.transaction do
      # NOTE(Raj): We try to be as accurate as possible by using both scrape streams(serp, meta).
      new_product = Product.create!(
        source: 'product_scraper',
        visible: false,
        reviewed: false,
        name: meta_scrape_result[:name] || extracted_attrs[:name] || product_name,
        tagline: extracted_attrs[:tagline] || product_name,
        website_url: search_result[:website_url],
        # NOTE(Raj): We prioritise scraped og:description from website over serp
        description: meta_scrape_result[:description] || search_result[:description],
        twitter_url: search_result[:twitter_url] || meta_scrape_result[:twitter_links].last,
        facebook_url: search_result[:facebook_url] || meta_scrape_result[:facebook_links].last,
        instagram_url: search_result[:instagram_url] || meta_scrape_result[:instagram_links].last,
        logo_uuid: logo[:image_uuid],
      )

      if new_product.persisted?
        save_product_media(new_product, meta_scrape_result[:images])
        save_product_link(new_product, meta_scrape_result[:app_store_url]) if meta_scrape_result[:app_store_url].present?
        save_product_link(new_product, meta_scrape_result[:play_store_url]) if meta_scrape_result[:play_store_url].present?

        # NOTE(Raj): We now have a newly created product, save serp & Products::Scrapers::HTML::Meta scraped record for product.
        save_scrape_results(new_product, 'meta_scraper' => meta_scrape_result, 'serp_api' => search_result)
      end

      new_product
    end
  end

  private

  def upload_logo(image_url)
    if image_url.present?
      Image::Upload.call(image_url)
    else
      {}
    end
  rescue Image::Upload::FormatError
    # NOTE(Raj): Ignore any malformed img urls, unsupported img formats from scrape.
    {}
  end

  # NOTE(Raj): Save scraped og/twitter images.
  def save_product_media(product, media = [])
    return unless product.present? && media.compact_blank.present?

    media.uniq.each do |media_url|
      media_attrs = Image::Upload.call(media_url)

      # NOTE(Raj): We only scrape image media kind.
      product.media.create!(
        uuid: media_attrs[:image_uuid],
        kind: 'image',
        original_height: media_attrs[:original_height],
        original_width: media_attrs[:original_width],
        metadata: {},
      )
    end
  rescue Image::Upload::FormatError
    # NOTE(Raj): Ignore any malformed img urls, unsupported img formats from scrape.
    {}
  end

  # NOTE(Raj): save app_store, play_store links for product in product_links table.
  def save_product_link(product, link)
    return unless product.present? && link.present?

    product.links.create!(
      source: 'scraper',
      url_kind: 'store',
      url: link,
    )
  end

  # NOTE(RAJ): Saves/updates raw data we get from both serp_api and meta scrape of existing/newly created product.
  def save_scrape_results(product, data)
    return unless product.present? && data.present?

    scrape_record = Products::ScrapeResult.find_by(
      product: product,
      source: 'product_scraper',
    )

    if scrape_record.present?
      scrape_record.data = { **scrape_record.data, **data }

      scrape_record.save!
    else
      Products::ScrapeResult.create!(
        product: product,
        url: product.website_url,
        data: data,
        source: 'product_scraper',
      )
    end
  end

  # NOTE(Raj): Extracts tagline and name when scraped tagline is of the format,
  #            'Product name | tagline' or similar.
  def extract_attrs_from_tagline(tagline, product_name)
    result_array = tagline.to_s.tr('|', '-').split(' - ')

    return { tagline: tagline } if result_array.size != 2 || product_name.blank?

    name_array = result_array.select do |value|
      value.casecmp?(product_name) || value.downcase.include?(product_name.downcase)
    end

    {
      name: name_array.first,
      tagline: (result_array - name_array).first,
    }
  end
end
