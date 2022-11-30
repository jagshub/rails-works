# frozen_string_literal: true

module Teams::Requests::Approve
  extend self

  def call(request:, approval_type:, status_changed_by: nil, role: nil)
    ApplicationRecord.transaction do
      update_request(request, approval_type, status_changed_by)
      create_team_member(request, role)

      send_email(request)
    end

    request
  end

  private

  def update_request(request, approval_type, status_changed_by)
    if approval_type == :manual && !status_changed_by
      raise ArgumentError, 'status_changed_by must be present for manual approval'
    end

    request.update!(
      status: :approved,
      status_changed_at: Time.current,
      approval_type: approval_type,
      status_changed_by: status_changed_by,
    )
  end

  def create_team_member(request, role)
    Team::Member.create!(
      product: request.product,
      user: request.user,
      team_email: request.team_email,
      role: role || default_role(request),
      referrer: request,
    )
  end

  def default_role(request)
    # Note(DT): We do create an owner only for the first request.
    request.product.team_members.active.exists? ? :member : :owner
  end

  def send_email(request)
    TeamMailer.request_approved(request).deliver_later
  end
end
