# Unit Tests for Roll4Play Rails Application

This directory contains comprehensive unit tests for the Rails application models.

## Test Structure

### Test Files
- `test_helper.rb` - Main test configuration and helper methods
- `support/test_data_helper.rb` - Helper methods for creating test data
- `models/campaign_test.rb` - Tests for the Campaign model
- `models/player_test.rb` - Tests for the Player model  
- `models/session_test.rb` - Tests for the Session model
- `models/membership_test.rb` - Tests for the Membership model
- `models/integration_test.rb` - Integration tests for model interactions
- `run_tests.rb` - Simple test runner script

## Running Tests

### Using Rails Test Command
```bash
# Run all model tests
bin/rails test test/models/

# Run specific model tests
bin/rails test test/models/campaign_test.rb
bin/rails test test/models/player_test.rb

# Run a specific test method
bin/rails test test/models/campaign_test.rb:15
```

### Using the Test Runner Script
```bash
# Run all tests
ruby test/run_tests.rb

# Run specific test file
ruby test/run_tests.rb test/models/campaign_test.rb
```

### Using Ruby Directly
```bash
# Run all tests
ruby -Itest test/models/*_test.rb

# Run specific test file
ruby -Itest test/models/campaign_test.rb
```

## Test Coverage

### Campaign Model Tests
- **Validations**: Title, description, and system requirements
- **Associations**: Memberships, players, and sessions
- **Scopes**: by_system, recent, with_sessions, active
- **Instance Methods**: admin_players, member_players, last_session, upcoming_sessions

### Player Model Tests
- **Validations**: Name, email, and bio requirements
- **Associations**: Memberships and campaigns
- **Scopes**: search_by_name, with_campaigns, active
- **Instance Methods**: admin_of?, member_of?, campaigns_as_admin, campaigns_as_member, display_name

### Session Model Tests
- **Validations**: played_at and notes requirements
- **Associations**: Campaign relationship
- **Scopes**: past, upcoming, recent, chronological, this_month, last_month
- **Instance Methods**: past?, upcoming?, today?, this_week?

### Membership Model Tests
- **Validations**: Role requirements and uniqueness constraints
- **Associations**: Player and campaign relationships
- **Scopes**: admins, members, for_campaign, for_player
- **Instance Methods**: admin?, member?, can_manage_campaign?, can_edit_sessions?

### Integration Tests
- Complete campaign creation with players and sessions
- Cascading deletes for campaigns and players
- Complex session queries and time-based scopes
- Role-based permissions and access control

## Test Data Helper

The `TestDataHelper` module provides convenient methods for creating test data:

```ruby
# Create test players
player = create_test_player
player_with_attributes = create_test_player(name: "John Doe", email: "john@example.com")

# Create test campaigns
campaign = create_test_campaign
campaign_with_attributes = create_test_campaign(title: "My Campaign", system: "D&D 5e")

# Create test sessions
session = create_test_session(campaign)
session_with_attributes = create_test_session(campaign, played_at: 1.day.from_now, notes: "Test notes")

# Create test memberships
membership = create_test_membership(player, campaign)
admin_membership = create_test_membership(player, campaign, role: "admin")
```

## Writing New Tests

### Basic Test Structure
```ruby
require "test_helper"

class YourModelTest < ActiveSupport::TestCase
  def setup
    # Set up test data
    @your_model = create_test_your_model
  end

  test "should be valid with valid attributes" do
    assert @your_model.valid?
  end

  test "should require required field" do
    @your_model.required_field = nil
    assert_not @your_model.valid?
    assert_includes @your_model.errors[:required_field], "can't be blank"
  end

  # Add more tests...
end
```

### Test Categories
1. **Validations**: Test model validation rules
2. **Associations**: Test model relationships
3. **Scopes**: Test query scopes
4. **Instance Methods**: Test custom methods
5. **Edge Cases**: Test boundary conditions and error cases

### Best Practices
- Use descriptive test names that explain what is being tested
- Test both positive and negative cases
- Use the test data helper methods for consistent test data
- Group related tests with comments
- Test edge cases and error conditions
- Keep tests focused and independent

## Database Setup

Make sure your test database is set up:

```bash
# Create and migrate test database
bin/rails db:test:prepare

# Or manually
bin/rails db:create RAILS_ENV=test
bin/rails db:migrate RAILS_ENV=test
```

## Continuous Integration

These tests can be easily integrated into CI/CD pipelines:

```yaml
# Example GitHub Actions step
- name: Run tests
  run: |
    bin/rails db:test:prepare
    bin/rails test test/models/
```

## Troubleshooting

### Common Issues
1. **Database not set up**: Run `bin/rails db:test:prepare`
2. **Missing dependencies**: Ensure all gems are installed
3. **Test data conflicts**: Each test should clean up after itself
4. **Time-sensitive tests**: Use `travel_to` helper for time-based tests

### Debugging Tests
```ruby
# Add debugging output
test "should do something" do
  puts "Debug: #{@model.inspect}"
  assert @model.valid?
end
```

## Next Steps

Consider adding:
- Controller tests for API endpoints
- System tests for user interactions
- Factory tests using FactoryBot
- Performance tests for complex queries
- Security tests for authentication and authorization 