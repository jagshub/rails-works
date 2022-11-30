# frozen_string_literal: true

# NOTE(vesln):
#
# Since there is no easy way and cheap way to transfer the csrf token in the frontend anymore, we
# are switching to stateless CSRF protection.
#
# Protecting REST Services using custom request headers.
#
# Adding CSRF tokens, a double submit cookie and value, encrypted token, or other defense that involves
# changing the UI can frequently be complex or otherwise problematic. An alternate defense which is particularly well
# suited for AJAX endpoints is the use of a custom request header. This defense relies on the same-origin policy (SOP)
# restriction that only JavaScript can be used to add a custom header, and only within its origin. By default,
# browsers don't allow JavaScript to make cross origin requests.
#
# A particularly attractive custom header and value to use is: X-Requested-With: XMLHttpRequest

module CsrfProtection
  extend ActiveSupport::Concern

  included do |klass|
    def klass.protect_from_forgery_stateless
      skip_before_action :verify_authenticity_token
      before_action :verify_x_request_with_header, if: :user_signed_in?
    end

    def verify_x_request_with_header
      return if Rails.env.test? || request.get?
      raise "Invalid or missing X-Requested-With Header value - #{ request.headers['X-Requested-With'] }" unless request.xhr?
    end
  end
end
