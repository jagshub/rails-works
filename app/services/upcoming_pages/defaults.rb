# frozen_string_literal: true

class UpcomingPages::Defaults
  class << self
    def call(user)
      provider = if user.ship_lead
                   ::UpcomingPages::Defaults::ShipLeadProvider.new(user.ship_lead)
                 else
                   ::UpcomingPages::Defaults::BaseProvider.new
                 end

      new(user, provider).call
    end

    def default_background_image?(image_uuid)
      ::UpcomingPages::Defaults::Backgrounds.default_background_image?(image_uuid)
    end
  end

  attr_reader :user, :provider

  delegate :name, :tagline, :logo_uuid, :topic_ids, to: :provider

  def initialize(user, provider)
    @user = user
    @provider = provider
  end

  def call
    {
      background_image_uuid: background_image_uuid,
      name: name,
      success_text: success_text,
      tagline: tagline,
      what_text: what_text,
      who_text: who_text,
      why_text: why_text,
      template_name: template_name,
      logo_uuid: logo_uuid,
      topic_ids: topic_ids,
    }
  end

  private

  def who_text
    who_text = "Hi, I'm #{ user.ship_lead&.name || user.name },"

    who_text = if user.headline.present?
                 "#{ who_text } - #{ user.headline }"
               else
                 "#{ who_text } - the maker of #{ name }"
               end

    "<p>#{ who_text }</p>"
  end

  def what_text
    "<p>#{ provider.what_text }</p>"
  end

  def success_text
    '<p>Thank you for supporting our project</p>'
  end

  def background_image_uuid
    ::UpcomingPages::Defaults::Backgrounds.pick
  end

  def why_text
    '<p>Subscribe to get early access</p>'
  end

  def template_name
    design = provider.template_name
    design = UpcomingPageVariant::TEMPLATE_NAMES.first unless UpcomingPageVariant::TEMPLATE_NAMES.include? design
    design
  end
end
