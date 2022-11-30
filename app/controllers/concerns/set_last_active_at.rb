# frozen_string_literal: true

module SetLastActiveAt
  def self.included(klass)
    klass.send :after_action, :set_last_active_at
  end

  private

  def set_last_active_at
    return if current_user.nil? || current_user.last_active_at&.today?

    current_user.update!(
      last_active_ip: request.ip,
      last_active_at: Time.zone.now,
    )
  end
end
