# frozen_string_literal: true

# Note (k1): This hack is necessary due to a weird class collision bug with ActiveAdmin's built-in Comment class.
# This change was necessary for the Rails 4.2 upgrade and can be removed as soon as AA.register Comment works (Rails starts).
ActiveAdmin.register ::Comment, as: 'Commentx' do
  config.batch_actions = true
  menu label: 'Comments', parent: 'Others'

  controller do
    def scoped_collection
      Comment.includes(:user, :subject)
    end
  end

  permit_params(
    :body,
    :created_at,
    :parent_comment_id,
    :sticky,
    :subject_id,
    :subject_type,
    :user_id,
  )

  filter :id
  filter :body
  filter :sticky
  filter :subject_type, as: :select, collection: Comment::SUBJECT_TYPES.sort
  filter :subject_id
  filter :user_id
  filter :created_at

  index pagination_total: false do
    selectable_column

    column 'Id' do |comment|
      link_to comment.id, admin_commentx_path(comment)
    end

    column :body
    column :subject
    column :votes_count
    column :user
    column :created_at

    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)

    f.inputs 'Details' do
      f.input :subject_type, as: :select, collection: ::Comment::SUBJECT_TYPES, include_blank: false
      f.input :subject_id, label: 'Subject ID'
      f.input :sticky
      f.input :body
      f.input :user_id, label: 'User ID'
      f.input :parent_comment_id, label: 'Parent comment ID'
      f.input :hidden_at, as: :datetime_picker
      f.input :created_at, label: 'Created on', as: :datetime_picker
    end

    f.actions
  end

  action_item :hide_comment, only: :show, if: proc { !resource.hidden_at? } do
    link_to 'Hide Comment', action: :hide_comment
  end

  action_item :unhide_comment, only: :show, if: proc { resource.hidden_at? } do
    link_to 'Unhide Comment', action: :unhide_comment
  end

  member_action :hide_comment do
    resource.hide!

    redirect_to resource_path, notice: 'Comment was hidden'
  end

  member_action :unhide_comment do
    resource.unhide!

    redirect_to resource_path, notice: 'Comment was unhidden'
  end

  show do
    default_main_content

    panel 'Votes' do
      table_for commentx.votes do
        column :user

        VoteCheckResult.checks.each_key do |check|
          column check.titleize do |vote|
            vote_check_vote_ring_score(vote, check)
          end
        end

        column :score do |vote|
          Voting::Checks.vote_ring_score(vote)
        end

        column :credible
        column :created_at
      end
    end
  end
end
