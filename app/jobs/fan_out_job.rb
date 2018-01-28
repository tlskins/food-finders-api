# Write actions
class FanOutJob < ApplicationJob
  queue_as :default

  def perform(action)
    Rails.logger.info 'Running fan out job for - ' + action.metadata.inspect
    puts 'Running fan out job for - ' + action.metadata.inspect
    action.fan_out
  end
end
