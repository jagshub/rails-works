# frozen_string_literal: true

# Note(andreasklinger): Enables slugged urls for multiple resources
#   Used by posts, submissions and collections for now.

module Sluggable
  extend ActiveSupport::Concern

  included do
    extend FriendlyId

    private

    def slug_scope
      scope = self.class

      if friendly_id_config.respond_to? :scope
        scope_column = friendly_id_config.scope
        scope = scope.where(scope_column => send(scope_column))
      end

      scope
    end
  end

  module ClassMethods
    def sluggable(scope: nil, candidate: :name, use: %i(slugged history))
      if scope.nil?
        friendly_id :sluggable_candidates, use: Array(use)
        validates :slug, presence: true, uniqueness: true, length: { maximum: 255 }
      else
        friendly_id :sluggable_candidates, use: Array(use) + [:scoped], scope: scope
        validates :slug, presence: true, uniqueness: { scope: scope }, length: { maximum: 255 }
      end

      define_method(:sluggable_candidates) do
        [candidate, [candidate, :sluggable_sequence]]
      end

      define_method(:sluggable_sequence) do
        slug = normalize_friendly_id(send(candidate))

        slug_scope.where("slug ~* '^#{ slug }(-[0-9]+)?$'").count + 1
      end

      define_method(:should_generate_new_friendly_id?) do
        slug.blank? || send("#{ candidate }_changed?")
      end
    end
  end
end
