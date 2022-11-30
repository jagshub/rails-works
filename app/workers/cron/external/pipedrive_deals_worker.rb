# frozen_string_literal: true

class Cron::External::PipedriveDealsWorker < ApplicationJob
  include ActiveJobHandleNetworkErrors

  def perform
    result = External::PipedriveApi.get_deals(
      filter_id: Config.pipedrive_daily_filter_id,
    )

    result['data']&.each do |deal_info|
      deal = ::Redshift::PipedriveDeal.find_or_initialize_by(id: deal_info['id'])
      deal.update! deal_info.slice(
        'id',
        'status',
        'value',
        'currency',
        'active',
        'deleted',
        'add_time',
        'update_time',
        'stage_change_time',
        'won_time',
        'lost_time',
        'close_time',
        'owner_name',
      )
    end
  end
end
