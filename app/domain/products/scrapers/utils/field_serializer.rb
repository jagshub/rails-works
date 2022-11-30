# frozen_string_literal: true

module Products::Scrapers::Utils::FieldSerializer
  def self.included(klass)
    klass.extend(ClassMethods)
  end

  module ClassMethods
    def fields
      @fields ||= []
    end

    FIELD_ERROR_MSG = 'Field %s is not allowed! %s allowed'
    def field(name, &block)
      unless Product::SCRAPABLE_FIELDS.include?(name)
        raise format(
          FIELD_ERROR_MSG,
          name,
          Product::SCRAPABLE_FIELDS,
        )
      end

      fields << name
      define_method(name, &block)
    end
  end

  def to_h
    self.class.fields.map do |name|
      [name, public_send(name)]
    end.to_h.compact
  end
end
