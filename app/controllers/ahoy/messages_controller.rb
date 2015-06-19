module Ahoy
  class MessagesController < ActionController::Base
    before_filter :set_message

    def open
      if @message
        tracking = @message.trackings.build(kind: :open, opened_at: Time.now)
        tracking.save!
      end

      publish :open

      send_data Base64.decode64("R0lGODlhAQABAPAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw=="), type: "image/gif", disposition: "inline"
    end

    def click
      if @message
        tracking = @message.trackings.build(kind: :click, clicked_at: Time.now)

        unless @message.trackings.opened.any?
          open_tracking = @message.trackings.build(kind: :open, opened_at: tracking.clicked_at)
          open_tracking.save!
        end

        tracking.save!
      end

      url       = params[:url].to_s
      signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha1"), AhoyEmail.secret_token, url)

      publish :click, url: params[:url]

      if secure_compare(params[:signature], signature)
        redirect_to url
      else
        redirect_to main_app.root_url
      end
    end

    protected

    def set_message
      @message = AhoyEmail.message_model.where(token: params[:id]).first
    end

    def publish(name, event = {})
      AhoyEmail.subscribers.each do |subscriber|
        if subscriber.respond_to?(name)
          event[:message]    = @message
          event[:controller] = self

          subscriber.send name, event
        end
      end
    end

    # from https://github.com/rails/rails/blob/master/activesupport/lib/active_support/message_verifier.rb
    # constant-time comparison algorithm to prevent timing attacks
    def secure_compare(a, b)
      return false unless a.bytesize == b.bytesize

      l = a.unpack "C#{a.bytesize}"

      res = 0
      b.each_byte { |byte| res |= byte ^ l.shift }
      res == 0
    end
  end
end
