module Ahoy
  class Tracking < ActiveRecord::Base
    self.table_name = "ahoy_trackings"

    belongs_to :message, touch: true, foreign_key: 'ahoy_message_id'

    scope :opened, -> { where(kind: :open) }
    scope :clicked, -> { where(kind: :click) }

    after_save :set_user_bounce_status

    private

    def set_user_bounce_status
      user_klass = self.message.user_type.constantize
      user       = user_klass.find(self.message.user_id)

      status     = if (self.notification_kind == 'bounce' && self.bounce_type == 'permanent') || self.notification_kind == 'complaint'
        'hard_bounce'
      elsif self.notification_kind == 'bounce'
        'soft_bounce'
      else
        nil
      end

      user.update_attributes(bounce_status: status) if user.respond_to?('bounce_status=')
    end
  end
end
