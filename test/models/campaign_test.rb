require "test_helper"

class CampaignTest < ActiveSupport::TestCase
  def setup
    @campaign = create_test_campaign
  end

  # Validations
  test "should be valid with valid attributes" do
    assert @campaign.valid?
  end

  test "should require title" do
    @campaign.title = nil
    assert_not @campaign.valid?
    assert_includes @campaign.errors[:title], "can't be blank"
  end

  test "should require title to be at least 3 characters" do
    @campaign.title = "ab"
    assert_not @campaign.valid?
    assert_includes @campaign.errors[:title], "is too short (minimum is 3 characters)"
  end

  test "should require title to be at most 100 characters" do
    @campaign.title = "a" * 101
    assert_not @campaign.valid?
    assert_includes @campaign.errors[:title], "is too long (maximum is 100 characters)"
  end

  test "should require description" do
    @campaign.description = nil
    assert_not @campaign.valid?
    assert_includes @campaign.errors[:description], "can't be blank"
  end

  test "should require description to be at least 10 characters" do
    @campaign.description = "short"
    assert_not @campaign.valid?
    assert_includes @campaign.errors[:description], "is too short (minimum is 10 characters)"
  end

  test "should require description to be at most 1000 characters" do
    @campaign.description = "a" * 1001
    assert_not @campaign.valid?
    assert_includes @campaign.errors[:description], "is too long (maximum is 1000 characters)"
  end

  test "should require system" do
    @campaign.system = nil
    assert_not @campaign.valid?
    assert_includes @campaign.errors[:system], "can't be blank"
  end

  test "should require system to be at most 50 characters" do
    @campaign.system = "a" * 51
    assert_not @campaign.valid?
    assert_includes @campaign.errors[:system], "is too long (maximum is 50 characters)"
  end

  # Associations
  test "should have many memberships" do
    assert_respond_to @campaign, :memberships
  end

  test "should have many players through memberships" do
    assert_respond_to @campaign, :players
  end

  test "should have many sessions" do
    assert_respond_to @campaign, :sessions
  end

  test "should destroy associated memberships when destroyed" do
    player = create_test_player
    membership = create_test_membership(player, @campaign)
    membership_id = membership.id
    
    @campaign.destroy
    assert_nil Membership.find_by(id: membership_id)
  end

  test "should destroy associated sessions when destroyed" do
    session = create_test_session(@campaign)
    session_id = session.id
    
    @campaign.destroy
    assert_nil Session.find_by(id: session_id)
  end

  # Scopes
  test "by_system scope should filter campaigns by system" do
    dnd_campaign = create_test_campaign(system: "D&D 5e")
    pathfinder_campaign = create_test_campaign(system: "Pathfinder")
    
    dnd_campaigns = Campaign.by_system("D&D 5e")
    assert_includes dnd_campaigns, dnd_campaign
    assert_not_includes dnd_campaigns, pathfinder_campaign
  end

  test "recent scope should order campaigns by created_at desc" do
    old_campaign = create_test_campaign(created_at: 2.days.ago)
    new_campaign = create_test_campaign(created_at: 1.day.ago)
    
    recent_campaigns = Campaign.recent
    assert_equal new_campaign, recent_campaigns.first
    assert_equal old_campaign, recent_campaigns.last
  end

  test "with_sessions scope should return campaigns with sessions" do
    campaign_with_session = create_test_campaign
    create_test_session(campaign_with_session)
    campaign_without_session = create_test_campaign
    
    campaigns_with_sessions = Campaign.with_sessions
    assert_includes campaigns_with_sessions, campaign_with_session
    assert_not_includes campaigns_with_sessions, campaign_without_session
  end

  test "active scope should return campaigns with recent sessions" do
    active_campaign = create_test_campaign
    create_test_session(active_campaign, played_at: 15.days.ago)
    
    inactive_campaign = create_test_campaign
    create_test_session(inactive_campaign, played_at: 45.days.ago)
    
    active_campaigns = Campaign.active
    assert_includes active_campaigns, active_campaign
    assert_not_includes active_campaigns, inactive_campaign
  end

  # Instance methods
  test "admin_players should return players with admin role" do
    admin_player = create_test_player
    member_player = create_test_player
    create_test_membership(admin_player, @campaign, role: "admin")
    create_test_membership(member_player, @campaign, role: "member")
    
    admin_players = @campaign.admin_players
    assert_includes admin_players, admin_player
    assert_not_includes admin_players, member_player
  end

  test "member_players should return players with member role" do
    admin_player = create_test_player
    member_player = create_test_player
    create_test_membership(admin_player, @campaign, role: "admin")
    create_test_membership(member_player, @campaign, role: "member")
    
    member_players = @campaign.member_players
    assert_includes member_players, member_player
    assert_not_includes member_players, admin_player
  end

  test "last_session should return the most recent session" do
    first_session = create_test_session(@campaign, played_at: 1.day.ago)
    last_session = create_test_session(@campaign, played_at: 1.hour.ago)
    
    assert_equal last_session, @campaign.last_session
  end

  test "upcoming_sessions should return future sessions" do
    past_session = create_test_session(@campaign, played_at: 1.day.ago)
    upcoming_session = create_test_session(@campaign, played_at: 1.day.from_now)
    
    upcoming_sessions = @campaign.upcoming_sessions
    assert_includes upcoming_sessions, upcoming_session
    assert_not_includes upcoming_sessions, past_session
  end
end
