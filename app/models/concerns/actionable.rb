# Module for an object that can create a valid Action
module Actionable
  extend ActiveSupport::Concern
  extend ActiveModel::Callbacks

  included do
    after_create :autocreate_action

    has_one :action, as: :actionable
  end

  attr_accessor :dont_autobuild_on_create

  def autocreate_action
    puts 'autocreate_action called'
    return if action.present? || @dont_autobuild_on_create
    create_action
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
