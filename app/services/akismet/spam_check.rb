# frozen_string_literal: true

class Akismet::SpamCheck
  include HTTParty

  API_KEY = ENV.fetch('AKISMET_API_KEY')

  base_uri "https://#{ API_KEY }.rest.akismet.com/1.1"

  # https://akismet.com/development/api/#comment-check
  def initialize(comment_content:,
                 permalink:,
                 referrer:,
                 user_agent:,
                 user_ip:,
                 comment_author:,
                 comment_author_url: nil,
                 comment_author_email: nil,
                 comment_type:)

    # Note(andreasklinger): If this is done as CONSTANT rails gets confused by the load order
    default_options = { blog_lang: 'en',
                        blog: Routes.root_url }.freeze

    @options = default_options.merge(comment_content: comment_content,
                                     permalink: permalink,
                                     referrer: referrer,
                                     comment_type: comment_type,
                                     user_agent: user_agent,
                                     comment_author_email: comment_author_email,
                                     user_ip: user_ip,
                                     comment_author: comment_author,
                                     comment_author_url: comment_author_url,
                                     is_test: !Rails.env.production?)
  end

  def spam?
    spam_check = self.class.post('/comment-check', body: @options)
    spam_check.body == 'true'
  rescue Errno::ECONNRESET, Net::OpenTimeout, Errno::EHOSTUNREACH, SocketError, OpenSSL::SSL::SSLError
    false
  end
end
