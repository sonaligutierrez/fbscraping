require "test_helper"

class PostReactionsTest < ActiveSupport::TestCase
  test "scraping comments with paging" do
    post = posts(:three)
    VCR.use_cassette("fb_scraping_reactions") do
      assert_changes "PostReaction.count > 500"  do
        post.scraping_reactions
      end
    end
  end
end
