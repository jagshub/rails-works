# frozen_string_literal: true

# == Schema Information
#
# Table name: external_api_responses
#
#  id         :bigint(8)        not null, primary key
#  kind       :string           not null
#  params     :jsonb            not null
#  response   :json             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_external_api_responses_on_params_and_kind  (params,kind) USING gin
#
class External::APIResponse < ApplicationRecord
  include Namespaceable

  enum kind: {
    clearbit_company: 'clearbit_company',
    webshrinker: 'webshrinker',
    coinmarketcap: 'coinmarketcap',
  }

  class << self
    def fetch(args, &block)
      cache_response = find_or_initialize_by(args)
      return cache_response if cache_response.persisted?

      api_response = yield block
      cache_response.update!(response: api_response)
      cache_response
    end
  end
end
