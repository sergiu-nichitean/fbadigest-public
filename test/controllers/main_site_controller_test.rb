require 'test_helper'

class MainSiteControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get main_site_home_url
    assert_response :success
  end

  test "should get load_posts" do
    get main_site_load_posts_url
    assert_response :success
  end

end
