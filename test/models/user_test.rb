require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "has many conversations" do
    user = users(:one)
    assert_includes user.conversations, conversations(:one)
  end
end
