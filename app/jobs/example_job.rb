# Write actions
class ExampleJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info 'Example Job!'
    # SocialEntry.create(text: "Example Job!", user: User.last)
  end
end
