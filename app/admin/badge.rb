# frozen_string_literal: true

ActiveAdmin.register Badge do
  menu label: 'Awarded Badges', parent: 'Badges'

  config.clear_action_items!
  config.batch_actions = false
  config.per_page = 20
  config.paginate = true

  permit_params :subject_id, :subject_type, :type, :position, :category, :year, :period, :date, :identifier

  scope(:top_post_daily) { |scope| scope.with_data(period: 'daily') }
  scope(:top_post_weekly) { |scope| scope.with_data(period: 'weekly') }
  scope(:top_post_monthly) { |scope| scope.with_data(period: 'monthly') }

  filter :id
  filter :subject_id
  filter :type, as: :select, collection: [Badges::GoldenKittyAwardBadge, Badges::TopPostBadge, Badges::UserAwardBadge, Badges::TopPostTopicBadge]

  index pagination_total: false do
    selectable_column
    column :id
    column :subject
    column :type
    column :data
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      if badge.type == Badges::UserAwardBadge.name
        row :award
        row :in_progress?
        row :awarded_to_user_and_visible?
        row :locked_and_hidden_by_admin?
        row :created_at
        row :updated_at
      else
        row :subject
        row :type
        row :data
        row :created_at
      end
    end
  end

  controller do
    def new
      if params[:type] == 'golden_kitty'
        @badge = Badge.new type: Badges::GoldenKittyAwardBadge.name, subject_type: Post.name
      elsif params[:type] == 'top_post'
        @badge = Badges::TopPostBadge.new type: Badges::TopPostBadge.name, subject_type: Post.name
      elsif params[:type] == 'top_post_topic'
        @badge = Badges::TopPostTopicBadge.new type: Badges::TopPostTopicBadge.name, subject_type: Post.name
      elsif params[:type] == 'user_award'
        @badge = Badges::UserAwardBadge.new type: Badges::UserAwardBadge.name, subject_type: User.name
      else
        redirect_to action: :index, notice: 'Invalid badge type'
      end
    end

    def create
      data = permitted_params[:badge]

      if data['type'] == Badges::TopPostBadge.name && data['date'].blank?
        post = Post.find(data['subject_id'])
        data['date'] = (post.featured_at || post.scheduled_at).to_date
      end

      @badge = Badge.new data
      @badge.save
      @badge.subject.refresh_badges_count if data['type'] == Badges::UserAwardBadge.name

      if @badge.subject.is_a?(Post) && @badge.subject.new_product.present?
        # Rebuild activities to include this new badge
        Products::RefreshActivityEvents.new(@badge.subject.new_product).call
      end

      respond_with @badge, location: admin_badges_path
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)

    if f.object.type == Badges::UserAwardBadge.name
      f.inputs 'Badge' do
        f.input :subject_id, as: :reference, label: 'User ID'
        f.input :subject_type, as: :reference, input_html: { readonly: true }
        f.input :type, as: :string, input_html: { readonly: true }
      end
    else
      f.inputs 'Badge' do
        f.input :subject_id, as: :reference, label: 'Post ID'
        f.input :subject_type, as: :reference, input_html: { readonly: true }
        f.input :type, as: :string, input_html: { readonly: true }
      end
    end

    if f.object.type == Badges::GoldenKittyAwardBadge.name
      f.inputs 'Details' do
        f.input :position, as: :string
        f.input :category, as: :string
        f.input :year, as: :string
      end
    elsif f.object.type == Badges::TopPostBadge.name
      f.inputs 'Details' do
        f.input :position, as: :string
        f.input :period, as: :select, collection: %w(daily weekly monthly)
        f.input :date, as: :string, required: false
      end
    elsif f.object.type == Badges::TopPostTopicBadge.name
      f.inputs 'Details' do
        f.input :position, as: :string
        f.input :period, as: :select, collection: %w(weekly monthly)
        f.input :date, as: :string, required: false
        f.input :topic_name, as: :string, required: true
      end
    elsif f.object.type == Badges::UserAwardBadge.name
      f.inputs 'Details' do
        f.input :identifier,
                label: 'Type of award',
                as: :select,
                collection: Badges::Award.identifiers.keys,
                required: true
      end
    end

    f.actions
  end

  action_item :new_golden_kitty_award_badge, only: :index do
    link_to('New Golden Kitty Badge', new_admin_badge_path(type: 'golden_kitty'))
  end

  action_item :new_top_post_badge, only: :index do
    link_to('New Top Post Badge', new_admin_badge_path(type: 'top_post'))
  end

  action_item :new_top_post_topic_badge, only: :index do
    link_to('New Top Topic Post Badge', new_admin_badge_path(type: 'top_post_topic'))
  end

  action_item :new_user_award_badge, only: :index do
    link_to('New User Award', new_admin_badge_path(type: 'user_award'))
  end

  action_item :hide_badge, only: :show do
    if resource.type == Badges::UserAwardBadge.name
      text = resource.locked_and_hidden_by_admin? ? 'Unlock award for user' : 'Lock and hide award for user'
      link_to text, action: 'lock_badge_for_user'
    end
  end

  action_item :move_to_awarded, only: :show do
    link_to 'Mark as awarded', action: 'force_award' if resource.type == Badges::UserAwardBadge.name
  end

  member_action :lock_badge_for_user do
    if !resource.locked_and_hidden_by_admin?
      resource.update!(data: resource.data.merge(status: :locked_and_hidden_by_admin))
      redirect_to admin_badge_path(type: 'user_award'), notice: 'Badge hidden from user and they will be unable to earn future awards of this type.'
    else
      resource.update!(data: resource.data.merge(status: UserBadges.award_for(identifier: resource.identifier)::DEFAULT_STATUS))
      redirect_to admin_badge_path(type: 'user_award'), notice: 'Badge reset and unlocked for user'
    end
    resource.subject.refresh_badges_count
  end

  member_action :force_award do
    resource.update!(data: resource.data.merge(status: :awarded_to_user_and_visible))
    redirect_to admin_badge_path(type: 'user_award'), notice: 'Badge awarded to user'
    resource.subject.refresh_badges_count
  end
end
