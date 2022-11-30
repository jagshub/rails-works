# frozen_string_literal: true

module HandleInvalidUnicode
  INVALID_UNICODES = [
    # clones of grave and acute; deprecated in Unicode
    "\u0340", "\u0341",
    # obsolete characters for Khmer; deprecated in Unicode
    "\u17A3", "\u17D3",
    # line and paragraph separator
    "\u2028", "\u2029",
    # BIDI embedding controls
    "\u202A", "\u202B", "\u202C", "\u202D", "\u202E",
    # activate/inhibit symmetric swapping; deprecated in Unicode
    "\u206A", "\u206B",
    # activate/inhibit Arabic form shaping; deprecated in Unicode
    "\u206C", "\u206D",
    # activate/inhibit national digit shapes; deprecated in Unicode
    "\u206E", "\u206F",
    # interlinear annotation characters
    "\uFFF9", "\uFFFA", "\uFFFB",
    # byte order mark
    "\uFEFF",
    # object replacement character
    "\uFFFC"
  ].freeze

  MATCH_ALL = Regexp.union(INVALID_UNICODES)

  def self.define(model, attrs = [])
    attrs = [attrs] if attrs.is_a? Symbol

    model.instance_eval do
      before_save do
        attrs.each do |attr|
          value = public_send(attr)

          next if value.blank?

          public_send("#{ attr }=", value.gsub(MATCH_ALL, ''))
        end
      end
    end
  end
end
