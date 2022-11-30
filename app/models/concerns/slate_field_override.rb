# frozen_string_literal: true

module SlateFieldOverride
  extend ActiveSupport::Concern

  module ClassMethods
    def slate_field(field, html_field: :"#{ field }_html", mode: :none)
      define_method "#{ field }=" do |input|
        self[html_field] = Sanitizers::ReactToDb.call(input, mode: mode)
      end

      define_method field do
        self[html_field]
      end
    end
  end
end
