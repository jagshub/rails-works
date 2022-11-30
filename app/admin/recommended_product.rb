# frozen_string_literal: true

ActiveAdmin.register RecommendedProduct do
  menu label: 'Ask -> Recommended Products', parent: 'Others'

  controller do
    def scoped_collection
      RecommendedProduct.includes(:product, :product_request, :new_product)
    end
  end

  permit_params(
    :name,
    :product_request_id,
    :product_id,
    :new_product_id,
    :score_multiplier,
  )

  filter :id
  filter :name
  filter :created_at

  index do
    selectable_column

    column 'Id' do |recommended_product|
      link_to recommended_product.id, admin_recommended_product_path(recommended_product)
    end

    column :name
    column :product_request
    column :new_product
    column :votes_count
    column :score_multiplier
    column :created_at

    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)

    f.inputs 'Details' do
      f.input :name, as: :string
      f.input :product_request_id, as: :reference, label: 'Product Request ID'
      f.input :product_id, as: :reference, label: '[Legacy] Product ID'
      f.input :new_product_id, as: :reference, label: 'Product ID'
      f.input :score_multiplier, hint: 'Multiplies the credible_vote count. If you put 2.0 here, it will rank as if it has 2x the votes it actually has'
    end

    f.actions
  end

  show do
    default_main_content

    panel 'Recommendations' do
      table_for recommended_product.recommendations.includes(:user) do
        column 'Id' do |recommendation|
          link_to recommendation.id, admin_recommendation_path(recommendation)
        end

        column :body
        column :user
        column 'Votes', &:votes_count
        column 'Credible Votes', &:credible_votes_count
        column :created_at

        column 'Show' do |recommendation|
          link_to 'Show', admin_recommendation_path(recommendation)
        end

        column 'Edit' do |recommendation|
          link_to 'Edit', edit_admin_recommendation_path(recommendation)
        end

        column 'Delete' do |recommendation|
          link_to 'Delete', admin_recommendation_path(recommendation), method: :delete
        end
      end
    end

    panel 'Votes' do
      table_for recommended_product.votes.includes(:user, :check_results) do
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
