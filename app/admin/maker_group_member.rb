# frozen_string_literal: true

ActiveAdmin.register MakerGroupMember do
  menu label: 'Makers -> Group Members', parent: 'Others'

  controller do
    def scoped_collection
      MakerGroupMember.includes %i(group user)
    end

    def new
      @maker_group_member = Admin::Maker::GroupMemberForm.new
    end

    def create
      @maker_group_member = Admin::Maker::GroupMemberForm.new assessed_by: current_user
      @maker_group_member.update permitted_params[:maker_group_member]

      respond_with @maker_group_member, location: admin_maker_group_members_path
    end

    def update
      @maker_group_member = Admin::Maker::GroupMemberForm.new member: find_resource, assessed_by: current_user
      @maker_group_member.update permitted_params[:maker_group_member]

      respond_with @maker_group_member, location: admin_maker_group_member_path
    end
  end

  permit_params Admin::Maker::GroupMemberForm.attribute_names

  filter :id
  filter :maker_group_id
  filter :user_id
  filter :role, as: :select, collection: MakerGroupMember.roles
  filter :state, as: :select, collection: MakerGroupMember.states
  filter :created_at
  filter :assessed_at

  batch_action :accept do |ids|
    batch_action_collection.find(ids).each do |member|
      Maker::GroupMembers.accept member, assessed_by: current_user, source: :admin
    end

    notice = "Successfully accepted #{ ids.count } maker group member(s)"
    redirect_to admin_maker_group_members_path, notice: notice
  end

  batch_action :decline do |ids|
    batch_action_collection.find(ids).each do |member|
      Maker::GroupMembers.decline member, assessed_by: current_user
    end

    notice = "Successfully declined #{ ids.count } maker group member(s)"
    redirect_to admin_maker_group_members_path, notice: notice
  end

  index do
    selectable_column

    column 'Id' do |member|
      link_to member.id, admin_maker_group_member_path(member)
    end

    column :group
    column :user
    column :role
    column :state
    column :created_at
    column :assessed_at

    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)

    f.inputs 'Details' do
      f.input :maker_group_id, as: :reference, label: 'Group ID', required: true
      f.input :user_id, as: :reference, label: 'User ID'
      f.input :role, as: :select, collection: MakerGroupMember.roles.keys.to_a, include_blank: false
      f.input :state, as: :select, collection: MakerGroupMember.states.keys.to_a, include_blank: false
    end

    f.actions
  end

  show do
    attributes_table do
      row :id
      row :group
      row :user
      row :role
      row :state
      row :assessed_by
      row :assessed_at
      row :created_at
      row :updated_at
    end
  end
end
