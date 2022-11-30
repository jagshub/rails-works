# frozen_string_literal: true

module FindConst
  extend self

  def call(parent_const, subject)
    subject_class = subject.class.name.tr('::', '')

    "::#{ parent_const.name }::#{ subject_class }".constantize
  end
end
