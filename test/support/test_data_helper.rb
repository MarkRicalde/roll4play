module TestDataHelper
  def create_test_player(attributes = {})
    Player.create!({
      name: "Test Player",
      email: "test@example.com",
      password: "password123",
      bio: "A test player bio"
    }.merge(attributes))
  end

  def create_test_campaign(attributes = {})
    Campaign.create!({
      title: "Test Campaign",
      description: "A test campaign description that meets the minimum length requirement",
      system: "D&D 5e"
    }.merge(attributes))
  end

  def create_test_session(campaign, attributes = {})
    Session.create!({
      campaign: campaign,
      played_at: 1.day.from_now,
      notes: "Test session notes"
    }.merge(attributes))
  end

  def create_test_membership(player, campaign, attributes = {})
    Membership.create!({
      player: player,
      campaign: campaign,
      role: "member"
    }.merge(attributes))
  end
end 