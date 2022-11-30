# frozen_string_literal: true

# NOTE(DZ): Adds `url_params_str` attribute in model. Default expected column
# is :url_params (json or jsonb compatible), null: false.
#
# Required migration:
#   add_column :table, :url_params, :json, default: {}, null: false
#

module HasUrlParams
  extend ActiveSupport::Concern

  included do
    attr_accessor :url_params_str

    def url_params_str
      self[:url_params].to_query
    end

    def url_params_str=(value)
      self[:url_params] = Rack::Utils.parse_nested_query value
    end
  end
end
