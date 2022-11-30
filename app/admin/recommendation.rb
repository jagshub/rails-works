# frozen_string_literal: true

ActiveAdmin.register Recommendation do
  menu label: 'Ask -> Recommendations', parent: 'Others'

  controller do
    def scoped_collection
      Recommendation.includes [{ recommended_product: :product }, :user]
    end
  end

  permit_params(
    :body,
    :disclosed,
    :highlighted,
    :user_id,
    :recommended_product_id,
  )

  filter :id
  filter :body
  filter :disclosed
  filter :highlighted
  filter :user_id
  filter :created_at
  filter :edited_at

  index do
    selectable_column

    column 'Id' do |recommendation|
      link_to recommendation.id, admin_recommendation_path(recommendation)
    end

    column :body
    column :disclosed
    column :user
    column :comments_count
    column :votes_count
    column :created_at
    column :edited_at

    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)

    f.inputs 'Details' do
      f.input :body
      f.input :disclosed
      f.input :highlighted
      f.input :recommended_product_id, as: :reference, label: 'Recommended Product ID'
      f.input :user_id, as: :reference, label: 'User ID'
    end

    f.actions
  end

  show do
    default_main_content

    panel 'Comments' do
      table_for recommendation.comments do
        column 'Id' do |comment|
          link_to comment.id, admin_commentx_path(comment)
        end

        column :body
        column :user
        column 'Votes', &:votes_count
        column :created_at

        column 'Show' do |comment|
          link_to 'Show', admin_commentx_path(comment)
        end

        column 'Edit' do |comment|
          link_to 'Edit', edit_admin_commentx_path(comment)
        end

        column 'Delete' do |comment|
          link_to 'Delete', admin_commentx_path(comment), method: :delete
        end
      end
    end

    panel 'Votes' do
      table_for recommendation.votes.includes(:user, :check_results) do
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
