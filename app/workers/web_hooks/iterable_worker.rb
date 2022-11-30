# frozen_string_literal: true

# NOTE(Bharat): Payload example. https://support.iterable.com/hc/en-us/articles/208013936-System-Webhooks-
# {
#     email: 'example@email.com',
#     eventName: 'emailOpen',
#     dataFields: {
#       campaignId: 5023667,
#       campaignName: 'Badge Mail',
#       workflowId: 290146,
#       workflowName: 'New Badge earned',
#       templateName: 'Badge Earned',
#       locale: null,
#       channelId: 67391,
#       messageTypeId: 83299,
#       experimentId: null,
#       labels: [],
#       emailSubject: 'Hooray! You have earned {{badgeName}} badge.',
#       userAgent: 'Mozilla/5.0 (Windows NT 5.1; rv:11.0) Gecko Firefox/11.0 (via ggpht.com GoogleImageProxy)',
#       ip: '66.249.84.22',
#       templateId: 6810007,
#       userAgentDevice: 'Gmail',
#       proxySource: 'Gmail',
#       email: 'example@email.com',
#       createdAt: '2022-09-12 07:49:10 +00:00',
#       messageId: '5d7d33ba4c3f423eae9db8aa0817d903',
#       emailId: 'c5023667:t6810007:example@email.com'
#     }

class WebHooks::IterableWorker
  include Sidekiq::Worker

  ALLOWED_EVENTS = [
    'emailOpen',
    'emailSend',
    'emailClick',
    'emailBounce',
    'emailComplaint',
    'emailSendSkip',
    'hostedUnsubscribeClick',
  ].freeze

  def perform(payload = {})
    return unless ALLOWED_EVENTS.include?(payload['eventName'])

    Iterable::EventWebhookDatum.create!(
      event_name: payload['eventName'],
      email: payload['email'],
      workflow_name: payload['dataFields']['workflowName'],
      campaign_name: payload['dataFields']['campaignName'],
      data_fields: payload['dataFields'],
    )
  end
end
