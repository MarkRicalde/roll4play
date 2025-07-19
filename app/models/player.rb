class Player < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :memberships, dependent: :destroy
  has_many :campaigns, through: :memberships

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :bio, length: { maximum: 500 }, allow_blank: true

  # Scopes
  scope :search_by_name, ->(name) { where('name ILIKE ?', "%#{name}%") }
  scope :with_campaigns, -> { joins(:campaigns).distinct }
  scope :active, -> { joins(:memberships).distinct }

  # Instance methods
  def admin_of?(campaign)
    memberships.find_by(campaign: campaign)&.admin?
  end

  def member_of?(campaign)
    memberships.exists?(campaign: campaign)
  end

  def campaigns_as_admin
    campaigns.joins(:memberships).where(memberships: { player: self, role: 'admin' })
  end

  def campaigns_as_member
    campaigns.joins(:memberships).where(memberships: { player: self, role: 'member' })
  end

  def display_name
    name.presence || email.split('@').first
  end
end