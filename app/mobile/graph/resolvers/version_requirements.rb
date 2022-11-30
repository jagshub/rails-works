# frozen_string_literal: true

class Mobile::Graph::Resolvers::VersionRequirements < Mobile::Graph::Resolvers::BaseResolver
  argument :level, Mobile::Graph::Types::VersionLevelEnum, required: true
  argument :os, Mobile::Graph::Types::VersionOsEnum, required: true

  type Mobile::Graph::Types::VersionRequirementType, null: false

  # NOTE(rstankov): We use the `Setting` model to store minimum requirements.
  #   The setting is controlled from:
  #     https://www.producthunt.com/admin/settings/
  #
  #   The setting name format is:
  #     mobile_version_requirements_[os]_[level]
  #
  #     os - ios, android
  #     level - alpha, beta, production
  #
  #   Examples:
  #     mobile_version_requirements_ios_alpha
  #     mobile_version_requirements_android_production
  #
  #   The setting format is:
  #     [required_version]|[required_build]|[recommend_version]|[recommend_build]
  #
  #   Examples:
  #     1.0|11|2.0|22 -> required version 1.0, build 11, recommend version 2.0, build 22
  #
  #   When no setting is available, we return 0 for all fields.
  #   Values are strings.
  #
  def resolve(os:, level:)
    setting_name = "mobile_version_requirements_#{ os.downcase }_#{ level.downcase }"
    setting = Setting.where(name: setting_name).first
    values = setting&.value.to_s.split('|')

    {
      min_required_version: extract(values[0]),
      min_required_build: extract(values[1]),
      min_recommended_version: extract(values[2]),
      min_recommended_build: extract(values[3]),
    }
  end

  private

  def extract(value)
    value.presence || '0'
  end
end
