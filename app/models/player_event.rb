class PlayerEvent < ActiveRecord::Base
  belongs_to :map
  belongs_to :weapon
  belongs_to :server
  belongs_to :player
  belongs_to :event
  belongs_to :trigger
  belongs_to :role
end
