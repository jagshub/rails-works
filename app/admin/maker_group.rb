# frozen_string_literal: true

ActiveAdmin.register MakerGroup do
  menu label: 'Makers -> Groups', parent: 'Others'

  controller do
    def find_resource
      scoped_collection.find params[:id]
    end

    def new
      @maker_group = Admin::Maker::GroupForm.new MakerGroup.new, owner: current_user
    end

    def create
      @maker_group = Admin::Maker::GroupForm.new MakerGroup.new, owner: current_user
      @maker_group.update permitted_params[:maker_group]

      respond_with @maker_group, location: admin_maker_groups_path
    end

    def edit
      @maker_group = Admin::Maker::GroupForm.new find_resource
    end

    def update
      @maker_group = Admin::Maker::GroupForm.new find_resource
      @maker_group.update permitted_params[:maker_group]

      respond_with @maker_group, location: admin_maker_groups_path
    end
  end

  permit_params Admin::Maker::GroupForm.attribute_names

  filter :id
  filter :name
  filter :kind, as: :select, collection: MakerGroup.kinds
  filter :created_at

  index do
    selectable_column

    column 'Id' do |group|
      link_to group.id, admin_maker_group_path(group)
    end

    column :name
    column :tagline
    column :kind
    column 'Members', :members_count
    column :created_at

    column 'Pending' do |group|
      link_to(group.pending_members_count, admin_maker_group_members_path('q[maker_group_id_equals]': group.id, 'q[state_eq]': 0))
    end

    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)

    f.inputs 'Details' do
      f.input :name
      f.input :tagline, hint: 'It is best to keep taglines long enough that they are sufficiently descriptive, but not longer than necessary'
      f.input :description, as: :text, hint: 'It is encouraged to use punctuation'
      f.input :instructions_html, as: :text, label: 'Instructions'
      f.input :kind, include_blank: false, as: :select, collection: MakerGroup.kinds.map { |(kind, _)| [kind.humanize, kind] }
    end

    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :tagline
      row :description
      row :instructions_html
      row :kind
      row 'Members' do |group|
        link_to group.members_count, admin_maker_group_members_path(q: { maker_group_id_equals: group.id })
      end
      row :created_at
      row :updated_at
    end
  end

  action_item :bulk_create_members, only: :show do
    link_to 'Bulk Create Members', action: :bulk_create_members
  end

  action_item :create_thread, only: :show do
    link_to 'Create Thread', new_admin_discussion_thread_path(
      subject_type: resource.class.name,
      subject_id: resource.id,
    )
  end

  member_action :bulk_create_members, method: %i(get patch) do
    @obj = MakerGroups.bulk_create_members_form.new(resource)

    if request.get?
      render 'admin/maker_group/bulk_create_members'
    else
      @obj.update params.require(:bulk_create).permit(:user_ids)

      redirect_to(
        admin_maker_group_path(resource),
        notice: "#{ @obj.users_created } users created for #{ resource.name }",
      )
    end
  end
end
