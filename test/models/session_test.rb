require "test_helper"

class SessionTest < ActiveSupport::TestCase
  def setup
    @campaign = create_test_campaign
    @session = create_test_session(@campaign)
  end

  # Validations
  test "should be valid with valid attributes" do
    assert @session.valid?
  end

  test "should require played_at" do
    @session.played_at = nil
    assert_not @session.valid?
    assert_includes @session.errors[:played_at], "can't be blank"
  end

  test "should allow notes to be blank" do
    @session.notes = nil
    assert @session.valid?
  end

  test "should require notes to be at most 2000 characters" do
    @session.notes = "a" * 2001
    assert_not @session.valid?
    assert_includes @session.errors[:notes], "is too long (maximum is 2000 characters)"
  end

  test "should not allow played_at to be more than a year in the future" do
    @session.played_at = 2.years.from_now
    assert_not @session.valid?
    assert_includes @session.errors[:played_at], "cannot be more than a year in the future"
  end

  test "should allow played_at to be exactly one year in the future" do
    @session.played_at = 1.year.from_now
    assert @session.valid?
  end

  test "should allow played_at to be in the past" do
    @session.played_at = 1.day.ago
    assert @session.valid?
  end

  # Associations
  test "should belong to campaign" do
    assert_respond_to @session, :campaign
  end

  test "should require campaign" do
    @session.campaign = nil
    assert_not @session.valid?
    assert_includes @session.errors[:campaign], "must exist"
  end

  # Scopes
  test "past scope should return sessions in the past" do
    past_session = create_test_session(@campaign, played_at: 1.day.ago)
    future_session = create_test_session(@campaign, played_at: 1.day.from_now)
    
    past_sessions = Session.past
    assert_includes past_sessions, past_session
    assert_not_includes past_sessions, future_session
  end

  test "upcoming scope should return sessions in the future" do
    past_session = create_test_session(@campaign, played_at: 1.day.ago)
    future_session = create_test_session(@campaign, played_at: 1.day.from_now)
    
    upcoming_sessions = Session.upcoming
    assert_includes upcoming_sessions, future_session
    assert_not_includes upcoming_sessions, past_session
  end

  test "recent scope should order sessions by played_at desc" do
    old_session = create_test_session(@campaign, played_at: 2.days.ago)
    new_session = create_test_session(@campaign, played_at: 1.day.ago)
    
    recent_sessions = Session.recent
    assert_equal new_session, recent_sessions.first
    assert_equal old_session, recent_sessions.last
  end

  test "chronological scope should order sessions by played_at asc" do
    old_session = create_test_session(@campaign, played_at: 2.days.ago)
    new_session = create_test_session(@campaign, played_at: 1.day.ago)
    
    chronological_sessions = Session.chronological
    assert_equal old_session, chronological_sessions.first
    assert_equal new_session, chronological_sessions.last
  end

  test "this_month scope should return sessions in current month" do
    this_month_session = create_test_session(@campaign, played_at: Time.current)
    last_month_session = create_test_session(@campaign, played_at: 1.month.ago)
    
    this_month_sessions = Session.this_month
    assert_includes this_month_sessions, this_month_session
    assert_not_includes this_month_sessions, last_month_session
  end

  test "last_month scope should return sessions in previous month" do
    this_month_session = create_test_session(@campaign, played_at: Time.current)
    last_month_session = create_test_session(@campaign, played_at: 1.month.ago)
    
    last_month_sessions = Session.last_month
    assert_includes last_month_sessions, last_month_session
    assert_not_includes last_month_sessions, this_month_session
  end

  # Instance methods
  test "past? should return true for past sessions" do
    @session.played_at = 1.day.ago
    assert @session.past?
  end

  test "past? should return false for future sessions" do
    @session.played_at = 1.day.from_now
    assert_not @session.past?
  end

  test "past? should return false for current time" do
    @session.played_at = Time.current
    assert_not @session.past?
  end

  test "upcoming? should return true for future sessions" do
    @session.played_at = 1.day.from_now
    assert @session.upcoming?
  end

  test "upcoming? should return false for past sessions" do
    @session.played_at = 1.day.ago
    assert_not @session.upcoming?
  end

  test "upcoming? should return false for current time" do
    @session.played_at = Time.current
    assert_not @session.upcoming?
  end

  test "today? should return true for sessions today" do
    @session.played_at = Time.current
    assert @session.today?
  end

  test "today? should return false for sessions not today" do
    @session.played_at = 1.day.ago
    assert_not @session.today?
  end

  test "this_week? should return true for sessions this week" do
    @session.played_at = Time.current
    assert @session.this_week?
  end

  test "this_week? should return true for sessions at beginning of week" do
    @session.played_at = Time.current.beginning_of_week
    assert @session.this_week?
  end

  test "this_week? should return true for sessions at end of week" do
    @session.played_at = Time.current.end_of_week
    assert @session.this_week?
  end

  test "this_week? should return false for sessions not this week" do
    @session.played_at = 2.weeks.ago
    assert_not @session.this_week?
  end
end
