# frozen_string_literal: true

module HasTimeAsFlag
  extend self

  def define(model, name, enable: nil, disable: nil, reverse: nil, after_action: nil)
    attribute_name = "#{ name }_at".to_sym

    mode = Module.new do
      define_method "#{ name }?" do
        date = public_send(attribute_name)
        !!date && date <= Time.current
      end

      if reverse
        define_method "#{ reverse }?" do
          date = public_send(attribute_name)
          !date || date > Time.current
        end
      end

      if enable
        define_method enable do
          current = Time.current
          send(after_action, current) if after_action

          update! attribute_name => current
        end
      end

      if disable
        define_method disable do
          send(after_action, nil) if after_action

          update! attribute_name => nil
        end
      end
    end

    model.include(mode)
    model.scope name.to_sym, -> { where(arel_table[attribute_name].lt(Time.current)) }
    model.scope (reverse || "not_#{ name }").to_sym, -> { where(arel_table[attribute_name].eq(nil)) }
  end
end
