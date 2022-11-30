# frozen_string_literal: true

# Note(kristian): include Namespaceable in prefixed classes,
module Namespaceable
  extend ActiveSupport::Concern

  module ClassMethods
    def table_name_prefix
      "#{ module_parent.name.underscore }_"
    end
  end
end
