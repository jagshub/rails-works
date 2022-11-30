# frozen_string_literal: true

class Admin::Maker::GroupForm
  include MiniForm::Model

  ATTRIBUTES = %i(
    description
    instructions_html
    kind
    name
    tagline
  ).freeze

  model :group, attributes: ATTRIBUTES, read: %i(id persisted? new_record?), save: true

  attr_reader :owner

  def initialize(group, owner: nil)
    @group = group
    @owner = owner
  end

  def to_model
    group
  end

  private

  def before_update
    @is_new_record = group.new_record?

    true
  end

  def after_update
    return unless @is_new_record
    return if owner.blank?

    form = Admin::Maker::GroupMemberForm.new assessed_by: owner
    form.update maker_group_id: group.id, role: :owner, state: :accepted, user_id: owner.id
  end
end
