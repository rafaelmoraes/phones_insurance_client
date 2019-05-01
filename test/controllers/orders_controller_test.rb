# frozen_string_literal: true

require 'test_helper'

class OrdersControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    stub_request(:get, 'http://localhost:3000/orders')
      .to_return(status: 200, body: '{"orders": []}')

    get orders_url
    assert_response :success
  end

  test 'should get new' do
    get new_order_url
    assert_response :success
  end

  test 'should create order' do
    expected = { imei: '123123123123123',
                 phone_model: 'V11',
                 annual_price: '1600.5',
                 installments: 10,
                 user: { id: 123 } }

    stub_request(:post, 'http://localhost:3000/orders')
      .to_return(
        status: 200,
        body: expected.merge(id: 123).to_json
      )

    post orders_url, params: { order: expected }

    assert_redirected_to orders_url
    assert_equal 'Order was successfully created.', flash[:notice]
  end
end
