# frozen_string_literal: true

class Ads::Admin::BudgetForm < Admin::BaseForm
  include ActionView::Helpers::NumberHelper

  ATTRIBUTES = %i(
    cta_text
    name
    tagline
    thumbnail
    url
    url_params
    amount
    campaign_id
    end_time
    kind
    start_time
    active_start_hour
    active_end_hour
    daily_cap_amount
  ).freeze

  MEDIA_ATTRIBUTES = %i(id media image_uuid priority _destroy).freeze

  NEWSLETTER_ATTRIBUTES = %i(
    active
    name
    tagline
    thumbnail
    thumbnail_uuid
    url
    url_params_str
    weight
    _destroy
    _create
  ).freeze

  NEWSLETTER_SPONSOR_ATTRIBUTES = %i(
    active
    body_image
    body_image_uuid
    cta
    description_html
    image
    image_uuid
    url
    url_params_str
    weight
    _destroy
    _create
  ).freeze

  NESTED_ATTRIBUTES = {
    channels: %i(
      id
      kind
      bundle
      active
      url
      url_params_str
      weight
      application
      cta_text
      name
      tagline
      thumbnail
      url
      url_params
    ),
    media: MEDIA_ATTRIBUTES,
    newsletter: NEWSLETTER_ATTRIBUTES,
    newsletter_sponsor: NEWSLETTER_SPONSOR_ATTRIBUTES,
  }.freeze

  model :budget,
        attributes: ATTRIBUTES,
        nested_attributes: NESTED_ATTRIBUTES,
        save: true

  main_model :budget, Ads::Budget

  attributes :unit_price, :impressions, :channel_kinds
  attributes :create_newsletter, :create_newsletter_sponsor

  delegate_missing_to :budget

  delegate :thumbnail_url, to: :budget

  validate :new_newsletter_has_not_been_sent?
  validate :new_newsletter_can_be_for_timed_budgets?
  validate :newsletter_can_be_destroyed?
  validate :newsletter_sponsor_is_valid?
  validate :newsletter_sponsor_can_be_destroyed?

  def initialize(budget = nil)
    @budget = budget || Ads::Budget.cpm.new
  end

  def newsletter
    return budget.newsletter if budget.newsletter.present?

    budget.build_newsletter(
      budget.campaign.attributes.slice(*NEWSLETTER_ATTRIBUTES.map(&:to_s)),
    )
  end

  def can_create_newsletter?
    budget.newsletter.new_record?
  end

  def can_destroy_newsletter?
    budget.newsletter.can_be_destroyed?
  end

  def newsletter_attributes=(values)
    destroy, create = values.values_at('_destroy', '_create')
    values = values.except('_destroy', '_create')

    if destroy == '1'
      budget.newsletter.mark_for_destruction
    elsif create == '1' || budget.newsletter.present?
      budget.newsletter || budget.build_newsletter
      budget.newsletter.attributes = values
      budget.newsletter.thumbnail_uuid ||= budget.campaign.thumbnail_uuid
    end
  end

  def newsletter_sponsor
    return budget.newsletter_sponsor if budget.newsletter_sponsor.present?

    budget.build_newsletter_sponsor(
      url: budget.campaign.url,
      url_params_str: budget.campaign.url_params_str,
    )
  end

  def can_create_newsletter_sponsor?
    budget.newsletter_sponsor.new_record?
  end

  def can_destroy_newsletter_sponsor?
    budget.newsletter_sponsor.can_be_destroyed?
  end

  def newsletter_sponsor_attributes=(values)
    destroy, create = values.values_at('_destroy', '_create')
    values = values.except('_destroy', '_create')

    if destroy == '1'
      budget.newsletter_sponsor.mark_for_destruction
    elsif create == '1' || budget.newsletter_sponsor.present?
      budget.newsletter_sponsor || budget.build_newsletter_sponsor
      budget.newsletter_sponsor.attributes = values
    end
  end

  def unit_price=(value)
    budget.unit_price = parse_currency value
  end

  def unit_price
    number_to_currency budget.unit_price
  end

  def amount=(value)
    budget.amount = parse_currency value
  end

  def amount
    number_to_currency budget.amount
  end

  def impressions
    number_with_precision budget.impressions, precision: 0, delimiter: ','
  end

  private

  def parse_currency(value)
    value.is_a?(String) ? value.scan(/[.0-9]/).join.to_d : value
  end

  def new_newsletter_has_not_been_sent?
    newsletter = budget.newsletter

    return unless newsletter.present? && newsletter.changed?
    return unless newsletter.newsletter&.sent?

    errors.add :newsletter, 'has already been sent'
  end

  def newsletter_can_be_destroyed?
    newsletter = budget.newsletter
    return unless newsletter.present? && newsletter.marked_for_destruction?
    return if newsletter.can_be_destroyed?

    errors.add :newsletter, 'can not be destroyed'
  end

  def new_newsletter_can_be_for_timed_budgets?
    newsletter = budget.newsletter
    return unless budget.timed?
    return unless newsletter.present? && newsletter.newsletter_id.nil?

    errors.add :newsletter, 'newsletter id cannot be nil for timed budgets'
  end

  def newsletter_sponsor_is_valid?
    return if budget.newsletter_sponsor.blank?
    return if budget.cpm?

    errors.add :newsletter_sponsor, 'is invalid, can only be added for cpm'
  end

  def newsletter_sponsor_can_be_destroyed?
    sponsor = budget.newsletter_sponsor
    return unless sponsor.present? && sponsor.marked_for_destruction?
    return if sponsor.can_be_destroyed?

    errors.add :newsletter_sponsor, 'can not be destroyed'
  end
end
