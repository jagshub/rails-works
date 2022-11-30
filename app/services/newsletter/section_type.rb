# frozen_string_literal: true

class Newsletter::SectionType < ActiveRecord::Type::Value
  def type
    :jsonb
  end

  def cast(input)
    convert_to_array(input).map do |value|
      case value
      when Newsletter::Section then value
      when Hash then Newsletter::Section.new(value)
      else raise "Invalid type - #{ value } (expected Hash or Section)"
      end
    end
  end

  def deserialize(value)
    case value
    when String then cast(decoded_json(value))
    else super
    end
  end

  def serialize(value)
    case value
    when Array then encode_json(value.map(&:to_h))
    else super
    end
  end

  private

  def convert_to_array(value)
    case value
    when ActionController::Parameters then value.values
    when Hash then value.values
    when Array then value
    when nil then []
    else raise "Array expected #{ value } given"
    end
  end

  def encode_json(value)
    ::ActiveSupport::JSON.encode(value)
  end

  def decoded_json(value)
    ::ActiveSupport::JSON.decode(value)
  rescue StandardError
    nil
  end
end
