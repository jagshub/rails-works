# frozen_string_literal: true

module HasUniqueCode
  extend self

  def define(model, field_name:, length: 10, expires_in: 1.month)
    model.instance_eval do
      before_validation on: :create do
        if self[field_name].blank?
          generated_code = ::HasUniqueCode.generate_code(self, field_name: field_name, length: length)
          assign_attributes(field_name => generated_code)
        end

        if self.class.column_names.include?("#{ field_name }_expires_at")
          assign_attributes("#{ field_name }_expires_at" => expires_in.from_now)
        end
      end
    end
  end

  # Note: Here we need to divide per 2 the length that we give to generate
  # method because SecureRandom.hex return a number that is the double of
  # what we want(it returns the base-16 representation of that sequence).
  # You can read more here:
  # http://stackoverflow.com/questions/15048622/why-does-the-securerandomhex-method-double-its-length-parameter-n
  def generate_code(model, field_name:, length:)
    loop do
      code = length.even? ? SecureRandom.hex(length / 2) : SecureRandom.hex((length + 1) / 2).chop
      return code unless model.class.exists? field_name => code
    end
  end
end
