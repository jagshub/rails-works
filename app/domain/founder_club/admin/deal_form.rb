# frozen_string_literal: true

class FounderClub::Admin::DealForm
  include MiniForm::Model

  model :deal, save: true, attributes: %i(
    title
    summary
    company_name
    details
    terms
    how_to_claim
    redemption_url
    logo
    logo_with_colors
    value
    priority
    active
    redemption_method
    badges
    product_id
  )

  Admin::UseForm.extend_form(self, :deal)

  delegate :trashed?, :logo_url, :logo_with_colors_url, :unlimited?, to: :deal

  attributes :unlimited_code, :limited_codes_csv

  after_update :update_limited_redemption_codes
  after_update :update_unlimited_redemption_code, if: :unlimited?
  after_update :remove_unlimited_redemption_code, unless: :unlimited?

  def initialize(deal = nil)
    @deal = deal || FounderClub::Deal.new(redemption_method: :unlimited)
  end

  def unlimited_code
    @unlimited_code || deal.redemption_codes.unlimited.first&.code
  end

  def unlimited_code=(value)
    @unlimited_code = value.strip
  end

  def badges=(value)
    deal.badges = Array(value).reject(&:blank?)
  end

  private

  def update_limited_redemption_codes
    return if @limited_codes_csv.nil?

    scope = deal.redemption_codes.limited

    CSV
      .new(@limited_codes_csv.read, headers: true)
      .to_a
      .map { |row| row[0] }
      .group_by(&:itself).transform_values(&:count)
      .each { |(code, limit)| scope.create!(code: code, limit: limit) unless scope.where(code: code).exists? }
  end

  def update_unlimited_redemption_code
    return if @unlimited_code.nil?

    redemption_code = deal.redemption_codes.unlimited.first || deal.redemption_codes.unlimited.build
    redemption_code.update! code: @unlimited_code if redemption_code.code != @unlimited_code
  end

  def remove_unlimited_redemption_code
    deal.redemption_codes.unlimited.find_each do |redemption_code|
      if redemption_code.claims_count > 0
        redemption_code.disabled!
      else
        redemption_code.destroy!
      end
    end
  end
end
