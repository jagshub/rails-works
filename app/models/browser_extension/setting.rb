# frozen_string_literal: true

# == Schema Information
#
# Table name: browser_extension_settings
#
#  id                        :bigint(8)        not null, primary key
#  user_id                   :bigint(8)
#  visitor_id                :string
#  background_image_mode     :boolean          default(FALSE), not null
#  beta_mode                 :boolean          default(FALSE), not null
#  dark_mode                 :boolean          default(FALSE), not null
#  home_view_variant         :string(32)       default("grid"), not null
#  show_goals_and_co_working :boolean          default(FALSE), not null
#  show_random_product       :boolean          default(TRUE), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  locality                  :string
#
# Indexes
#
#  index_browser_extension_settings_on_user_id     (user_id) UNIQUE
#  index_browser_extension_settings_on_visitor_id  (visitor_id) UNIQUE
#

class BrowserExtension::Setting < ApplicationRecord
  include Namespaceable

  belongs_to :user, inverse_of: :browser_extension_setting, optional: true

  validate :user_id_or_visitor_id_is_present
  validate :home_view_variant_is_valid

  class << self
    def find_or_initialize_with(graphql_context)
      current_user = graphql_context[:current_user]
      visitor_id = graphql_context[:cookies]&.[](:visitor_id)

      key, value =
        if current_user.present?
          [:user_id, current_user.id]
        else
          [:visitor_id, visitor_id]
        end

      BrowserExtension::Setting.find_or_initialize_by(key => value)
    end
  end

  private

  def user_id_or_visitor_id_is_present
    return if user_id.present? || visitor_id.present?

    errors.add :base, 'user or visitor_id must exist'
  end

  def home_view_variant_is_valid
    return unless home_view_variant.present? && ['grid', 'column'].exclude?(home_view_variant)

    errors.add :home_view_variant, :invalid
  end
end
