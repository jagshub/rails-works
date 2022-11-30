# frozen_string_literal: true

# NOTE(DZ): Makes a model flaggable.
#
# Required database columns for the model:
#
#   add_column :collections, :user_flags_count, :integer, null: false, default: 0
#
# Also add your class name to Flags::SUBJECTS and handle in Flags::NotifyAdmins
#
# Add to the moderation flag resolver app/graph/resolvers/moderation/flags_resolver.rb

module UserFlaggable
  extend ActiveSupport::Concern

  included do
    has_many :user_flags, class_name: 'Flag', as: :subject, dependent: :destroy
  end
end
