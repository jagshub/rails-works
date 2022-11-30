# frozen_string_literal: true

class Admin::Maker::GroupMemberForm
  include MiniForm::Model

  ATTRIBUTES = %i(
    maker_group_id
    role
    state
    user_id
  ).freeze

  model :member, attributes: ATTRIBUTES, save: true

  attr_reader :assessed_by

  def initialize(member: nil, assessed_by: nil)
    @member = member || MakerGroupMember.new(state: :accepted)
    @assessed_by = assessed_by
  end

  def to_model
    member
  end

  private

  def before_update
    member.assessed_at = member.pending? ? nil : DateTime.current
    member.assessed_by = member.pending? ? nil : assessed_by

    @is_new_record = member.new_record?
    @member_changes = member.changes.except(:assessed_at, :assessed_by)

    true
  end

  def after_update
    # NOTE(DZ): Turn off member notification for now
    # event_name = @is_new_record ? :maker_group_member_created : :maker_group_member_updated

    # ApplicationEvents.trigger(
    #   event_name,
    #   member: member,
    #   member_changes: @member_changes,
    # )

    true
  end
end
