# frozen_string_literal: true

module Mobile::ExtractInfoFromHeaders
  extend self

  def get_http_x_track_code(request)
    request.env['HTTP_X_TRACK_CODE'] if defined?(request.env)
  end

  def get_http_user_agent(request)
    request.env['HTTP_USER_AGENT'] if defined?(request.env)
  end

  def get_user_agent_info(request)
    # Example - "ProductHuntMobile|\(appVersion)|\(deviceModel)|\(osName)|\(osVersion)"
    user_agent_header = request.headers['User-Agent']
    if user_agent_header.present?
      header_parts = user_agent_header.split('|')
      if header_parts.count != 5
        return {
          app_version: nil,
          device_model: nil,
          os: nil,
          os_version: nil,
        }
      end

      _, app_version, device_model, os, os_version = header_parts
      {
        app_version: app_version,
        device_model: device_model,
        os: os.downcase,
        os_version: os_version,
      }
    else
      {
        app_version: nil,
        device_model: nil,
        os: nil,
        os_version: nil,
      }
    end
  end

  def get_mobile_source(request)
    return :mobile if request.blank?

    info = get_user_agent_info(request)
    info.presence[:os]&.to_sym || :mobile
  end
end
