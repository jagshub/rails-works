# frozen_string_literal: true

module DismissContent
  extend self
  include NewRelic::Agent::MethodTracer

  Response = Struct.new(:id, :dismissable_key, :dismissable_group, :is_dismissed)

  def call(cookies:, dismissable_key:, dismissable_group:, user:)
    if user.present?
      Dismissable.dismiss!(dismissable_group: dismissable_group, dismissable_key: dismissable_key, user: user)
    else
      cookies["#{ dismissable_key }-#{ dismissable_group }"] = Time.current.to_s
    end

    Response.new("#{ dismissable_key }-#{ dismissable_group }", dismissable_key, dismissable_group, true)
  end

  def dismissed(dismissable_key:, dismissable_group:, user:, cookies:)
    raise ArgumentError, 'user or cookies must be present' if user.blank? && cookies.blank?

    dismissed = if user.present?
                  Dismissable.find_by(dismissable_key: dismissable_key, dismissable_group: dismissable_group, user_id: user.id)
                else
                  cookies["#{ dismissable_key }-#{ dismissable_group }"].present?
                end

    Response.new("#{ dismissable_key }-#{ dismissable_group }", dismissable_key, dismissable_group, !!dismissed)
  end
  add_method_tracer :dismissed, 'DismissContent/dismissed'
end
