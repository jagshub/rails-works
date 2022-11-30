# frozen_string_literal: true

module StructuredData::Generator
  extend self

  def generator_for(subject)
    generator = "::StructuredData::Generators::#{ subject.class.name }".safe_constantize
    raise NotImplementedError, "You must implement a generator for #{ subject.class.name }'s" unless generator

    generator.structured_data_for(subject)&.delete_if { |_, v| v.nil? }
  end
end
