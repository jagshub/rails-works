# frozen_string_literal: true

# A reference field like `user_id`, is going to be a number, but we don't want
# a number input with up/down arrows. We'd prefer a plain string, but we don't
# want a maxlength, because it's going to be the size of the integer.
#
# Usage:
#
#   f.input :user_id, as: :reference
#
class ReferenceInput < Formtastic::Inputs::StringInput
  def input_html_options
    super.merge(maxlength: nil)
  end
end
