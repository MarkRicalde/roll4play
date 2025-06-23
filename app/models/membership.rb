class Membership < ApplicationRecord
  belongs_to :player
  belongs_to :campaign

  # Role attribute, e.g. 'admin', 'member', 'moderator'
  validates :role, presence: true, inclusion: { in: %w[admin member] }
end