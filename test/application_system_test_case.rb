# frozen_string_literal: true

require 'test_helper'
WebMock.disable_net_connect!(
  allow: 'https://chromedriver.storage.googleapis.com',
  allow_localhost: true
)
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1280, 720]
end
