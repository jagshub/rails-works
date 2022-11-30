# frozen_string_literal: true

# == Schema Information
#
# Table name: pipedrive_deals
#
#  id                 :integer          not null, primary key
#  status             :string(255)
#  value              :integer
#  currency           :string(255)
#  active             :boolean
#  deleted            :boolean
#  add_time           :datetime
#  update_time        :datetime
#  stage_change_time  :datetime
#  won_time           :datetime
#  lost_time          :datetime
#  close_time         :datetime
#  owner_name         :string(255)
#

# -*- SkipSchemaAnnotations
class Redshift::PipedriveDeal < Redshift::Base
  self.table_name = 'producthunt_production.pipedrive_deals'

  def readonly?
    false
  end
end
