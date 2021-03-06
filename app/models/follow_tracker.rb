# Tracks who a user is following or is followed by
class FollowTracker
  include Mongoid::Document
  include Mongoid::Timestamps

  field :target_ids, type: Array, default: []
  field :target_count, type: Integer, default: 0

  has_one :user

  def includes_target?(target)
    target_ids.include?(target.id) if target.present?
  end

  def add_target(target)
    return if target.nil? || target_ids.include?(target.id)
    target_ids << target.id
    update_attributes(target_ids: target_ids, target_count: target_count + 1)
    user.refresh_friends_count if user.present?
  end

  def find_target_index(target)
    target_ids.find_index(target.id) if target.present?
  end

  def remove_target(target)
    index = find_target_index(target)
    return if index.nil?
    target_ids.slice!(index)
    update_attributes(target_ids: target_ids, target_count: target_count - 1)
    user.refresh_friends_count if user.present?
  end

  def reset
    update_attributes(target_ids: [], target_count: 0)
    user.refresh_friends_count if user.present?
  end
end
