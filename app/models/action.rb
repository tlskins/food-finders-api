# Builds newsfeed items
class Action
  include Mongoid::Document
  include Mongoid::Timestamps

  field :conducted_at, type: DateTime
  field :scope, type: String # Followers, All
  field :fan_out_status, type: String # Pending, In Progress, Done

  belongs_to :actable, polymorphic: true

  validates :conducted_at, :scope, :fan_out_status, presence: true

  def actable_type=(params)
    super(params)
    write_actable_data
  end

  protected

  def write_actable_data
    self.scope = actable.scope
    self.fan_out_status = 'Pending'
    self.conducted_at = Time.now
  end
end
