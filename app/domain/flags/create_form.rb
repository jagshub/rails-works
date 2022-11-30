# frozen_string_literal: true

class Flags::CreateForm
  include MiniForm::Model

  model :flag, attributes: %i(reason subject), save: true

  def initialize(user, subject)
    @flag = user.present? && Flag.find_by(user: user, subject: subject) || Flag.new(user: user, subject: subject)
  end

  private

  def after_update
    Flags::NotifyAdmins.perform_later(flag)
  end
end
