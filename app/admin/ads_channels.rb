# frozen_string_literal: true

ActiveAdmin.register Ads::Channel, as: 'Channels' do
  menu label: 'Ads -> Channels', parent: 'Revenue'

  filter :budget_id_eq, label: 'BUDGET ID'
  filter :kind, as: :select, collection: Ads::Channel.kinds
  filter :application, as: :select, collection: Ads::Channel.applications
  filter :with_bundles,
         label: 'Bundle',
         as: :select,
         collection: Ads::Channel.bundles

  order_by :priority do |clause|
    if clause.order == 'desc'
      "weight desc, CASE ads_budgets.kind WHEN 'timed' then 0 else 1 END"
    else
      "weight asc, CASE ads_budgets.kind WHEN 'timed' then 1 else 0 END"
    end
  end

  actions :index

  includes budget: :campaign

  controller do
    def scoped_collection
      # NOTE(DZ): This join is used by admin `priority` sorting
      end_of_association_chain.left_joins(:budget)
    end
  end

  index do
    column :id
    column :campaign, sortable: 'ads_campaigns.name' do |resource|
      resource.budget.campaign
    end
    column :budget, sortable: 'ads_budgets.id', &:budget
    column :budget_kind, sortable: 'ads_budgets.kind' do |resource|
      resource.budget.kind
    end
    column :cpm, sortable: :unit_price do |resource|
      number_to_currency resource.budget.unit_price
    end
    column :kind
    column :bundle
    column :application
    column :impressions, :impressions_count
    column :click, :clicks_count
    column :active do |r|
      bip_status_tag r, :active, reload: true, url: bip_admin_channel_path(r)
    end
    column :priority, sortable: :priority do |r|
      bip_tag r, :weight, reload: true, url: bip_admin_channel_path(r)
    end
  end

  member_action :bip, method: :put do
    resource.update params[:ads_channel].permit!
    respond_with_bip resource
  end

  action_item :import, only: :index do
    link_to 'Import Interactions', action: 'import_interactions'
  end

  collection_action :import_interactions, method: %i(get post) do
    @import = Ads::Admin::ImportInteractionsForm.new

    if request.get?
      render 'admin/ads/import_interactions'
    else
      @import.update params.require(:import).permit(:csv)

      redirect_to collection_path, notice: 'Import running'
    end
  end
end
