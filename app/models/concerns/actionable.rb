# Module for an object that can create a valid Action
module Actionable
  extend ActiveSupport::Concern
  extend ActiveModel::Callbacks

  included do
    has_one :action, as: :actionable
  end

  def actor
    raise 'Actionable actor not defined'
  end

  def scope
    raise 'Actionable scope not defined'
  end

  def metadata
    raise 'Actionable metadata not defined'
  end
end
