# frozen_string_literal: true

module HasStrippableFields
  extend self

  def define(model, attributes:)
    model.instance_eval do
      before_save :strip_attributes

      private

      define_method(:strip_attributes) do
        attributes.each do |attribute|
          public_send("#{ attribute }=", public_send(attribute).strip) unless public_send(attribute).nil?
        end
      end
    end
  end
end
