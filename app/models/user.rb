class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :first_name, type: String
  field :last_name, type: String

  has_many :votes

  # TODO - what entities are my current best awards

  def name
    first_name + ' ' + last_name
  end
end
