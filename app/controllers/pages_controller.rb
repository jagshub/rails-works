# frozen_string_literal: true

class PagesController < ApplicationController
  def ping
    all_ok, check_output = HealthCheck.call
    render plain: check_output, status: (all_ok ? :ok : :service_unavailable)
  end

  def online
    render plain: 'OK'
  end
end
