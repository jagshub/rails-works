# frozen_string_literal: true

# NOTE(DZ): Module with methods for setting and identifying mailjet payloads
# if they're test emails. Used in AdminMailer#mailet_payload_test
module Admin::MailTest
  def test_email_event_payload(payload)
    email_event_payload payload.merge('test_payload' => '1')
  end

  def test_event?(event)
    payload = event['Payload']

    payload.present? &&
      payload.include?('test_payload') &&
      payload['test_payload'] == '1'
  end
end
