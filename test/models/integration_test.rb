require "test_helper"

class IntegrationTest < ActiveSupport::TestCase
  def setup
    @player = create_test_player
    @campaign = create_test_campaign
  end

  test "should create complete campaign with players and sessions" do
    # Create admin membership
    admin_membership = create_test_membership(@player, @campaign, role: "admin")
    
    # Create another player as member
    member_player = create_test_player(name: "Member Player", email: "member@example.com")
    member_membership = create_test_membership(member_player, @campaign, role: "member")
    
    # Create sessions
    past_session = create_test_session(@campaign, played_at: 1.week.ago, notes: "First session")
    upcoming_session = create_test_session(@campaign, played_at: 1.week.from_now, notes: "Next session")
    
    # Verify associations work correctly
    assert_equal 2, @campaign.players.count
    assert_equal 2, @campaign.memberships.count
    assert_equal 2, @campaign.sessions.count
    
    # Verify admin functionality
    assert @player.admin_of?(@campaign)
    assert member_player.member_of?(@campaign)
    assert_not member_player.admin_of?(@campaign)
    
    # Verify campaign methods
    assert_includes @campaign.admin_players, @player
    assert_includes @campaign.member_players, member_player
    assert_equal upcoming_session, @campaign.last_session
    assert_includes @campaign.upcoming_sessions, upcoming_session
    assert_not_includes @campaign.upcoming_sessions, past_session
  end

  test "should handle campaign deletion with cascading deletes" do
    # Create memberships and sessions
    member_player = create_test_player(name: "Member Player", email: "member@example.com")
    create_test_membership(@player, @campaign, role: "admin")
    create_test_membership(member_player, @campaign, role: "member")
    
    past_session = create_test_session(@campaign, played_at: 1.week.ago)
    upcoming_session = create_test_session(@campaign, played_at: 1.week.from_now)
    
    # Store IDs for verification
    membership_ids = @campaign.memberships.pluck(:id)
    session_ids = @campaign.sessions.pluck(:id)
    
    # Delete campaign
    @campaign.destroy
    
    # Verify cascading deletes
    membership_ids.each do |id|
      assert_nil Membership.find_by(id: id)
    end
    
    session_ids.each do |id|
      assert_nil Session.find_by(id: id)
    end
    
    # Verify players still exist
    assert Player.exists?(@player.id)
    assert Player.exists?(member_player.id)
  end

  test "should handle player deletion with cascading deletes" do
    # Create memberships
    member_player = create_test_player(name: "Member Player", email: "member@example.com")
    create_test_membership(@player, @campaign, role: "admin")
    create_test_membership(member_player, @campaign, role: "member")
    
    # Create another campaign
    other_campaign = create_test_campaign(title: "Other Campaign")
    create_test_membership(@player, other_campaign, role: "member")
    
    # Store membership IDs for verification
    player_membership_ids = @player.memberships.pluck(:id)
    
    # Delete player
    @player.destroy
    
    # Verify cascading deletes
    player_membership_ids.each do |id|
      assert_nil Membership.find_by(id: id)
    end
    
    # Verify campaigns still exist
    assert Campaign.exists?(@campaign.id)
    assert Campaign.exists?(other_campaign.id)
    
    # Verify other player still exists
    assert Player.exists?(member_player.id)
  end

  test "should handle complex session queries" do
    # Create multiple sessions at different times
    travel_to_time(Time.current) do
      today_session = create_test_session(@campaign, played_at: Time.current, notes: "Today's session")
      yesterday_session = create_test_session(@campaign, played_at: 1.day.ago, notes: "Yesterday's session")
      tomorrow_session = create_test_session(@campaign, played_at: 1.day.from_now, notes: "Tomorrow's session")
      last_month_session = create_test_session(@campaign, played_at: 1.month.ago, notes: "Last month's session")
      
      # Test scopes
      assert_equal 2, Session.past.count
      assert_equal 1, Session.upcoming.count
      assert_equal 1, Session.this_month.count
      assert_equal 1, Session.last_month.count
      
      # Test instance methods
      assert yesterday_session.past?
      assert_not yesterday_session.upcoming?
      assert today_session.today?
      assert today_session.this_week?
      assert_not yesterday_session.today?
    end
  end

  test "should handle role-based permissions" do
    # Create players with different roles
    admin_player = create_test_player(name: "Admin Player", email: "admin@example.com")
    member_player = create_test_player(name: "Member Player", email: "member@example.com")
    
    admin_membership = create_test_membership(admin_player, @campaign, role: "admin")
    member_membership = create_test_membership(member_player, @campaign, role: "member")
    
    # Test permission methods
    assert admin_membership.admin?
    assert admin_membership.can_manage_campaign?
    assert admin_membership.can_edit_sessions?
    
    assert_not member_membership.admin?
    assert member_membership.member?
    assert_not member_membership.can_manage_campaign?
    assert_not member_membership.can_edit_sessions?
    
    # Test player methods
    assert admin_player.admin_of?(@campaign)
    assert member_player.member_of?(@campaign)
    assert_not member_player.admin_of?(@campaign)
  end
end 