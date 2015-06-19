module Ahoy
  class Message < ActiveRecord::Base
    self.table_name = "ahoy_messages"

    belongs_to :user, polymorphic: true
    has_many :trackings, foreign_key: 'ahoy_message_id'
  end
end
