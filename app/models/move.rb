class Move < ApplicationRecord
  belongs_to :container
  validates :container_id, presence: true
end
