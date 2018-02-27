# Hashtag Model - an arbitrary subject topic
class Hashtag
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Taggable

  # Used to set taggable symbol in tag
  def tagging_symbol
    '#'
  end

  # Used to set a unique public tag identifier
  def tagging_raw_handle
    handlefy(name)
  end
end
