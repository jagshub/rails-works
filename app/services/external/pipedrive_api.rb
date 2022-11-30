# frozen_string_literal: true

module External::PipedriveApi
  extend self

  API_URL = 'https://producthunt.pipedrive.com/api/v1'
  API_KEY = Config.secret(:pipedrive_api_key)

  def get_deals(filter_id: nil, status: nil, limit: 500)
    url = "#{ API_URL }/deals"

    params = { api_token: API_KEY, limit: limit }
    params[:filter_id] = filter_id if filter_id.present?
    params[:status] = status if status.present?

    response = RestClient.get url, params: params
    JSON.parse(response.body)
  end
end
