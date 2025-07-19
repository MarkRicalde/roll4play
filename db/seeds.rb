# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Seeding database..."

# Create sample players
players = [
  { name: "Alex Johnson", email: "alex@example.com", bio: "Experienced DM who loves creating immersive worlds" },
  { name: "Sarah Chen", email: "sarah@example.com", bio: "Creative player who enjoys roleplaying and storytelling" },
  { name: "Mike Rodriguez", email: "mike@example.com", bio: "Tactical player who loves combat encounters" },
  { name: "Emma Wilson", email: "emma@example.com", bio: "New player excited to learn the game" }
]

players.each do |player_attrs|
  player = Player.find_or_create_by(email: player_attrs[:email]) do |p|
    p.name = player_attrs[:name]
    p.bio = player_attrs[:bio]
    p.password = "password123" # Default password for demo
  end
  puts "Created player: #{player.name}"
end

# Create sample campaigns
campaigns = [
  { title: "The Lost Mines of Phandelver", description: "A classic D&D 5e adventure for new players", system: "D&D 5e" },
  { title: "Curse of Strahd", description: "A gothic horror adventure in the land of Barovia", system: "D&D 5e" },
  { title: "Star Wars: Edge of the Empire", description: "A scoundrel's tale in the Outer Rim", system: "Star Wars RPG" },
  { title: "Call of Cthulhu: The Haunting", description: "Investigation of a haunted house in Boston", system: "Call of Cthulhu" }
]

campaigns.each do |campaign_attrs|
  campaign = Campaign.find_or_create_by(title: campaign_attrs[:title]) do |c|
    c.description = campaign_attrs[:description]
    c.system = campaign_attrs[:system]
  end
  puts "Created campaign: #{campaign.title}"
end

# Create memberships (players joining campaigns)
memberships = [
  { player_email: "alex@example.com", campaign_title: "The Lost Mines of Phandelver", role: "DM" },
  { player_email: "sarah@example.com", campaign_title: "The Lost Mines of Phandelver", role: "Player" },
  { player_email: "mike@example.com", campaign_title: "The Lost Mines of Phandelver", role: "Player" },
  { player_email: "emma@example.com", campaign_title: "The Lost Mines of Phandelver", role: "Player" },
  { player_email: "alex@example.com", campaign_title: "Curse of Strahd", role: "DM" },
  { player_email: "sarah@example.com", campaign_title: "Curse of Strahd", role: "Player" },
  { player_email: "mike@example.com", campaign_title: "Star Wars: Edge of the Empire", role: "DM" },
  { player_email: "emma@example.com", campaign_title: "Star Wars: Edge of the Empire", role: "Player" }
]

memberships.each do |membership_attrs|
  player = Player.find_by(email: membership_attrs[:player_email])
  campaign = Campaign.find_by(title: membership_attrs[:campaign_title])
  
  if player && campaign
    Membership.find_or_create_by(player: player, campaign: campaign) do |m|
      m.role = membership_attrs[:role]
    end
    puts "Created membership: #{player.name} as #{membership_attrs[:role]} in #{campaign.title}"
  end
end

# Create sample sessions
sessions = [
  { campaign_title: "The Lost Mines of Phandelver", played_at: 1.week.ago, notes: "First session! Players met in Phandelver and started investigating the Redbrands." },
  { campaign_title: "The Lost Mines of Phandelver", played_at: 3.days.ago, notes: "Explored the Redbrand hideout. Epic battle with the bugbear!" },
  { campaign_title: "Curse of Strahd", played_at: 2.weeks.ago, notes: "Arrived in Barovia. The atmosphere is already creepy and foreboding." },
  { campaign_title: "Star Wars: Edge of the Empire", played_at: 5.days.ago, notes: "Smuggling mission to Kessel. Things got complicated when the Empire showed up." }
]

sessions.each do |session_attrs|
  campaign = Campaign.find_by(title: session_attrs[:campaign_title])
  
  if campaign
    Session.find_or_create_by(campaign: campaign, played_at: session_attrs[:played_at]) do |s|
      s.notes = session_attrs[:notes]
    end
    puts "Created session for #{campaign.title} on #{session_attrs[:played_at].strftime('%B %d, %Y')}"
  end
end

puts "Database seeding completed!" 