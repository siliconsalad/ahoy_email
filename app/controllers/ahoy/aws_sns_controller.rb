module Ahoy
  class AwsSnsController < ActionController::Base

    def email_notification
      # Get the amazon message type and topic
      amz_message_type = request.headers['x-amz-sns-message-type']
      amz_sns_topic    = request.headers['x-amz-sns-topic-arn']

      # Return 404 if there is no amz_sns_topic
      return render(nothing: true, status: 404) if amz_sns_topic.nil?

      request_body = ActiveSupport::JSON.decode(request.body.read)

      # Confirm aws sns subscription
      # SNS ask for confirmation to valid sns topic subscription
      if amz_message_type.to_s.downcase == 'subscriptionconfirmation'
        send_subscription_confirmation request_body
      elsif amz_message_type.to_s.downcase == 'notification'
        process_notification request_body
      end

      render nothing: true, status: 200
    end

    private

    def send_subscription_confirmation(request_body)
      subscribe_url = request_body['SubscribeURL']

      return render(nothing: true, status: 404) if subscribe_url.to_s.empty?

      HTTParty.get subscribe_url
    end

    def process_notification(request_body)
      message        = JSON.parse request_body['Message']
      kind           = message['notificationType'].downcase
      recipients     = []
      delivery_time  = Time.now
      bounce_type    = bounce_sub_type = nil

      if message['notificationType'] == 'Delivery'
        delivery_object  = message['delivery']
        delivery_time    = message['mail']['timestamp']
        delivery_time    = delivery_time.to_time unless delivery_time.blank?
        recipients       = delivery_object['recipients']
      elsif message['notificationType'] == 'Bounce'
        bounce_object    = message['bounce']
        bounce_type      = bounce_object['bounceType'].downcase
        bounce_sub_type  = bounce_object['bounceSubType'].downcase
        delivery_time    = message['mail']['timestamp']
        delivery_time    = delivery_time.to_time unless delivery_time.blank?
        recipients       = bounce_object['bouncedRecipients'].map { |bounce| bounce['emailAddress'] }
      elsif message['notificationType'] == 'Complaint'
        complaint_object = message['complaint']
        delivery_time    = message['mail']['timestamp']
        delivery_time    = delivery_time.to_time unless delivery_time.blank?
        recipients       = complaint_object['complainedRecipients'].map { |complaint| complaint['emailAddress'] }
      end

      recipients.each do |recipient|
        message = Ahoy::Message.where(to: recipient).order(:sent_at).last

        if message
          message.update_attributes(email_status: kind)
          tracking = message.trackings.build({
            kind: :sns_notification,
            notified_at: delivery_time,
            notification_kind: kind,
            bounce_type: bounce_type,
            bounce_sub_type: bounce_sub_type
          })
          tracking.save!
        end
      end
    end

  end
end
