require "test_helper"

class PlayerTest < ActiveSupport::TestCase
  def setup
    @player = create_test_player
  end

  # Validations
  test "should be valid with valid attributes" do
    assert @player.valid?
  end

  test "should require name" do
    @player.name = nil
    assert_not @player.valid?
    assert_includes @player.errors[:name], "can't be blank"
  end

  test "should require name to be at least 2 characters" do
    @player.name = "a"
    assert_not @player.valid?
    assert_includes @player.errors[:name], "is too short (minimum is 2 characters)"
  end

  test "should require name to be at most 50 characters" do
    @player.name = "a" * 51
    assert_not @player.valid?
    assert_includes @player.errors[:name], "is too long (maximum is 50 characters)"
  end

  test "should require email" do
    @player.email = nil
    assert_not @player.valid?
    assert_includes @player.errors[:email], "can't be blank"
  end

  test "should require unique email" do
    duplicate_player = @player.dup
    assert_not duplicate_player.valid?
    assert_includes duplicate_player.errors[:email], "has already been taken"
  end

  test "should require valid email format" do
    @player.email = "invalid-email"
    assert_not @player.valid?
    assert_includes @player.errors[:email], "is invalid"
  end

  test "should allow bio to be blank" do
    @player.bio = nil
    assert @player.valid?
  end

  test "should require bio to be at most 500 characters" do
    @player.bio = "a" * 501
    assert_not @player.valid?
    assert_includes @player.errors[:bio], "is too long (maximum is 500 characters)"
  end

  # Associations
  test "should have many memberships" do
    assert_respond_to @player, :memberships
  end

  test "should have many campaigns through memberships" do
    assert_respond_to @player, :campaigns
  end

  test "should destroy associated memberships when destroyed" do
    campaign = create_test_campaign
    membership = create_test_membership(@player, campaign)
    membership_id = membership.id
    
    @player.destroy
    assert_nil Membership.find_by(id: membership_id)
  end

  # Scopes
  test "search_by_name scope should find players by name" do
    john_player = create_test_player(name: "John Doe")
    jane_player = create_test_player(name: "Jane Smith")
    
    john_players = Player.search_by_name("John")
    assert_includes john_players, john_player
    assert_not_includes john_players, jane_player
  end

  test "search_by_name scope should be case insensitive" do
    john_player = create_test_player(name: "John Doe")
    
    john_players = Player.search_by_name("john")
    assert_includes john_players, john_player
  end

  test "with_campaigns scope should return players with campaigns" do
    player_with_campaign = create_test_player
    campaign = create_test_campaign
    create_test_membership(player_with_campaign, campaign)
    
    player_without_campaign = create_test_player
    
    players_with_campaigns = Player.with_campaigns
    assert_includes players_with_campaigns, player_with_campaign
    assert_not_includes players_with_campaigns, player_without_campaign
  end

  test "active scope should return players with memberships" do
    active_player = create_test_player
    campaign = create_test_campaign
    create_test_membership(active_player, campaign)
    
    inactive_player = create_test_player
    
    active_players = Player.active
    assert_includes active_players, active_player
    assert_not_includes active_players, inactive_player
  end

  # Instance methods
  test "admin_of? should return true for admin membership" do
    campaign = create_test_campaign
    create_test_membership(@player, campaign, role: "admin")
    
    assert @player.admin_of?(campaign)
  end

  test "admin_of? should return false for member membership" do
    campaign = create_test_campaign
    create_test_membership(@player, campaign, role: "member")
    
    assert_not @player.admin_of?(campaign)
  end

  test "admin_of? should return false for no membership" do
    campaign = create_test_campaign
    
    assert_not @player.admin_of?(campaign)
  end

  test "member_of? should return true for any membership" do
    campaign = create_test_campaign
    create_test_membership(@player, campaign, role: "member")
    
    assert @player.member_of?(campaign)
  end

  test "member_of? should return true for admin membership" do
    campaign = create_test_campaign
    create_test_membership(@player, campaign, role: "admin")
    
    assert @player.member_of?(campaign)
  end

  test "member_of? should return false for no membership" do
    campaign = create_test_campaign
    
    assert_not @player.member_of?(campaign)
  end

  test "campaigns_as_admin should return campaigns where player is admin" do
    admin_campaign = create_test_campaign
    member_campaign = create_test_campaign
    create_test_membership(@player, admin_campaign, role: "admin")
    create_test_membership(@player, member_campaign, role: "member")
    
    admin_campaigns = @player.campaigns_as_admin
    assert_includes admin_campaigns, admin_campaign
    assert_not_includes admin_campaigns, member_campaign
  end

  test "campaigns_as_member should return campaigns where player is member" do
    admin_campaign = create_test_campaign
    member_campaign = create_test_campaign
    create_test_membership(@player, admin_campaign, role: "admin")
    create_test_membership(@player, member_campaign, role: "member")
    
    member_campaigns = @player.campaigns_as_member
    assert_includes member_campaigns, member_campaign
    assert_not_includes member_campaigns, admin_campaign
  end

  test "display_name should return name when present" do
    @player.name = "John Doe"
    assert_equal "John Doe", @player.display_name
  end

  test "display_name should return email prefix when name is blank" do
    @player.name = ""
    @player.email = "john.doe@example.com"
    assert_equal "john.doe", @player.display_name
  end

  test "display_name should return email prefix when name is nil" do
    @player.name = nil
    @player.email = "john.doe@example.com"
    assert_equal "john.doe", @player.display_name
  end
end
