# frozen_string_literal: true

# NOTE(Dhruv): Add source attribute to track model creation
# source e.g 'api-{APP_ID}'.
#
# Suggested migration:
#   add_column :votes, :source, :string
#

module HasApiActions
  extend self

  def define(model)
    model.instance_eval do
      scope :from_api, -> { where('source LIKE api%') }
    end
  end

  def source_to_identifier(source)
    "api-#{ source.id }" if source.is_a? Doorkeeper::Application
  end
end
