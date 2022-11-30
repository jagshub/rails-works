# frozen_string_literal: true

module Users::SyncHeader
  extend self

  HEADER_SERVICES = {
    'twitter' => TwitterApi::Banner,
  }.freeze

  def call(user, medium:, overwrite:)
    return if user.header_uuid.present? && !overwrite

    header = header(medium: medium, user: user)
    return if header.blank?

    user.header = header
    user.save!
  end

  private

  def header(medium:, user:)
    service = HEADER_SERVICES[medium]

    return if service.blank?

    service.call(user)
  end
end
