class Move < ApplicationRecord
  belongs_to :container
  validates :container_id, presence: true
  has_many_attached :images
end
