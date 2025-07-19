require "test_helper"

class MembershipTest < ActiveSupport::TestCase
  def setup
    @player = create_test_player
    @campaign = create_test_campaign
    @membership = create_test_membership(@player, @campaign)
  end

  # Validations
  test "should be valid with valid attributes" do
    assert @membership.valid?
  end

  test "should require role" do
    @membership.role = nil
    assert_not @membership.valid?
    assert_includes @membership.errors[:role], "can't be blank"
  end

  test "should require valid role" do
    @membership.role = "invalid_role"
    assert_not @membership.valid?
    assert_includes @membership.errors[:role], "is not included in the list"
  end

  test "should accept admin role" do
    @membership.role = "admin"
    assert @membership.valid?
  end

  test "should accept member role" do
    @membership.role = "member"
    assert @membership.valid?
  end

  test "should require unique player per campaign" do
    duplicate_membership = @membership.dup
    assert_not duplicate_membership.valid?
    assert_includes duplicate_membership.errors[:player_id], "is already a member of this campaign"
  end

  test "should allow same player in different campaigns" do
    other_campaign = create_test_campaign
    other_membership = create_test_membership(@player, other_campaign)
    assert other_membership.valid?
  end

  test "should allow different players in same campaign" do
    other_player = create_test_player
    other_membership = create_test_membership(other_player, @campaign)
    assert other_membership.valid?
  end

  # Associations
  test "should belong to player" do
    assert_respond_to @membership, :player
  end

  test "should belong to campaign" do
    assert_respond_to @membership, :campaign
  end

  test "should require player" do
    @membership.player = nil
    assert_not @membership.valid?
    assert_includes @membership.errors[:player], "must exist"
  end

  test "should require campaign" do
    @membership.campaign = nil
    assert_not @membership.valid?
    assert_includes @membership.errors[:campaign], "must exist"
  end

  # Scopes
  test "admins scope should return admin memberships" do
    admin_membership = create_test_membership(@player, @campaign, role: "admin")
    member_membership = create_test_membership(create_test_player, @campaign, role: "member")
    
    admin_memberships = Membership.admins
    assert_includes admin_memberships, admin_membership
    assert_not_includes admin_memberships, member_membership
  end

  test "members scope should return member memberships" do
    admin_membership = create_test_membership(@player, @campaign, role: "admin")
    member_membership = create_test_membership(create_test_player, @campaign, role: "member")
    
    member_memberships = Membership.members
    assert_includes member_memberships, member_memberships
    assert_not_includes member_memberships, admin_membership
  end

  test "for_campaign scope should return memberships for specific campaign" do
    other_campaign = create_test_campaign
    other_membership = create_test_membership(@player, other_campaign)
    
    campaign_memberships = Membership.for_campaign(@campaign)
    assert_includes campaign_memberships, @membership
    assert_not_includes campaign_memberships, other_membership
  end

  test "for_player scope should return memberships for specific player" do
    other_player = create_test_player
    other_membership = create_test_membership(other_player, @campaign)
    
    player_memberships = Membership.for_player(@player)
    assert_includes player_memberships, @membership
    assert_not_includes player_memberships, other_membership
  end

  # Instance methods
  test "admin? should return true for admin role" do
    @membership.role = "admin"
    assert @membership.admin?
  end

  test "admin? should return false for member role" do
    @membership.role = "member"
    assert_not @membership.admin?
  end

  test "member? should return true for member role" do
    @membership.role = "member"
    assert @membership.member?
  end

  test "member? should return false for admin role" do
    @membership.role = "admin"
    assert_not @membership.member?
  end

  test "can_manage_campaign? should return true for admin" do
    @membership.role = "admin"
    assert @membership.can_manage_campaign?
  end

  test "can_manage_campaign? should return false for member" do
    @membership.role = "member"
    assert_not @membership.can_manage_campaign?
  end

  test "can_edit_sessions? should return true for admin" do
    @membership.role = "admin"
    assert @membership.can_edit_sessions?
  end

  test "can_edit_sessions? should return false for member" do
    @membership.role = "member"
    assert_not @membership.can_edit_sessions?
  end

  # Constants
  test "ROLES constant should contain valid roles" do
    assert_includes Membership::ROLES, "admin"
    assert_includes Membership::ROLES, "member"
    assert_equal 2, Membership::ROLES.length
  end
end 