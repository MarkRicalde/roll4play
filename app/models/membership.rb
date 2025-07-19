class Membership < ApplicationRecord
  belongs_to :player
  belongs_to :campaign

  # Role enum for better management
  ROLES = %w[admin member].freeze
  
  validates :role, presence: true, inclusion: { in: ROLES }
  validates :player_id, uniqueness: { scope: :campaign_id, message: "is already a member of this campaign" }

  # Scopes
  scope :admins, -> { where(role: 'admin') }
  scope :members, -> { where(role: 'member') }
  scope :for_campaign, ->(campaign) { where(campaign: campaign) }
  scope :for_player, ->(player) { where(player: player) }

  # Instance methods
  def admin?
    role == 'admin'
  end

  def member?
    role == 'member'
  end

  def can_manage_campaign?
    admin?
  end

  def can_edit_sessions?
    admin?
  end
end