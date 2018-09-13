require "test_helper"

class ExtractDataWatirInBatchJobTest < ActiveJob::TestCase
  def setup
    @fb_post_photo = posts(:watir_1)
    @fb_post = posts(:watir_2)
  end

  test "scraping execution for a photo post" do
    VCR.use_cassette("fb_scraping_watir_photo", record: :new_episodes) do
      count = ExtractDataWatirInBatchJob.perform_now @fb_post_photo
      assert_equal(@fb_post_photo.post_comments.count, 119)
    end
  end

  test "scraping execution for a post" do
    VCR.use_cassette("fb_scraping_watir", record: :new_episodes) do
      count = ExtractDataWatirInBatchJob.perform_now @fb_post
      assert_equal(@fb_post.post_comments.count, 15)
    end
  end
end