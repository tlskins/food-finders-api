# Provides all the functionality so that an action object can be created from it
module Actionable
  extend ActiveSupport::Concern

  included do
    has_one :action, as: :actable
  end

  def actor
    user if user.present?
  end

  def scope
    'Followers'
  end

  def metadata
    'Test'
  end
end
