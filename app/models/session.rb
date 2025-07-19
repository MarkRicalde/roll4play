class Session < ApplicationRecord
  belongs_to :campaign

  # Validations
  validates :played_at, presence: true
  validates :notes, length: { maximum: 2000 }, allow_blank: true
  validate :played_at_cannot_be_too_far_in_future

  # Scopes
  scope :past, -> { where('played_at < ?', Time.current) }
  scope :upcoming, -> { where('played_at > ?', Time.current) }
  scope :recent, -> { order(played_at: :desc) }
  scope :chronological, -> { order(:played_at) }
  scope :this_month, -> { where(played_at: Time.current.beginning_of_month..Time.current.end_of_month) }
  scope :last_month, -> { where(played_at: 1.month.ago.beginning_of_month..1.month.ago.end_of_month) }

  # Instance methods
  def past?
    played_at < Time.current
  end

  def upcoming?
    played_at > Time.current
  end

  def today?
    played_at.to_date == Date.current
  end

  def this_week?
    played_at >= Time.current.beginning_of_week && played_at <= Time.current.end_of_week
  end

  private

  def played_at_cannot_be_too_far_in_future
    return unless played_at.present?

    if played_at > 1.year.from_now
      errors.add(:played_at, "cannot be more than a year in the future")
    end
  end
end