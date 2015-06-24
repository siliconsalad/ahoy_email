module Ahoy
  class Tracking < ActiveRecord::Base
    self.table_name = "ahoy_trackings"

    belongs_to :message, touch: true

    scope :opened, -> { where(kind: :open) }
    scope :clicked, -> { where(kind: :click) }
  end
end
