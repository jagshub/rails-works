# frozen_string_literal: true

class Ads::Ad
  delegate :kind, to: :@budget
  delegate :post, to: :@campaign

  attr_reader :id

  def initialize(channel)
    @id = channel.id
    @channel = channel
    @budget = channel.budget
    @campaign = channel.budget.campaign
  end

  %i(name tagline thumbnail_uuid media).each do |attribute|
    define_method(attribute) do
      @channel.public_send(attribute).presence || @budget.public_send(attribute).presence || @campaign.public_send(attribute)
    end
  end

  def cta_text
    @budget.cta_text.presence || @campaign.cta_text.presence
  end

  def url
    Routes.ads_redirect_path(id)
  end

  def channel_kind
    @channel.kind
  end
end
