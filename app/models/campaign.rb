class Campaign < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :players, through: :memberships
  has_many :sessions, dependent: :destroy

  # Validations
  validates :title, presence: true, length: { minimum: 3, maximum: 100 }
  validates :description, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :system, presence: true, length: { maximum: 50 }

  # Scopes
  scope :by_system, ->(system) { where(system: system) }
  scope :recent, -> { order(created_at: :desc) }
  scope :with_sessions, -> { joins(:sessions).distinct }
  scope :active, -> { joins(:sessions).where('sessions.played_at > ?', 30.days.ago).distinct }

  # Instance methods
  def admin_players
    players.joins(:memberships).where(memberships: { role: 'admin' })
  end

  def member_players
    players.joins(:memberships).where(memberships: { role: 'member' })
  end

  def last_session
    sessions.order(:played_at).last
  end

  def upcoming_sessions
    sessions.where('played_at > ?', Time.current)
  end
end