# frozen_string_literal: true

require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  test 'should has these attribute accessors' do
    order = Order.new
    %i[id imei phone_model installments
       annual_price user].each do |attribute|
      assert_respond_to order, attribute
      assert_respond_to order, "#{attribute}="
    end
  end

  test 'should #serializable_hash returns the correct hash' do
    expected = { id: nil,
                 imei: nil,
                 phone_model: nil,
                 installments: nil,
                 annual_price: nil,
                 user: nil }

    assert_equal expected, Order.new.serializable_hash
  end

  test 'should #refresh_instance! update instance with hash attributes' do
    expected = { id: 124,
                 imei: '888888888888888',
                 phone_model: 'Zenphone 2',
                 annual_price: '300.32',
                 installments: 3,
                 user: { id: 321,
                         name: 'Rafael Moraes',
                         cpf: '043.435.008-70',
                         email: 'rafaelmoraes@email.com' } }
    order = Order.new
    order.refresh_instance!(expected)
    expected.each do |key, value|
      assert_equal value, order.send(key) if key != :user
    end

    expected[:user].each do |key, value|
      assert_equal value, order.user.send(key)
    end
  end

  test 'should not store' do
    assert_not Order.new.store
  end

  test 'should has blank attribute error message' do
    order = Order.new
    %i[imei phone_model annual_price installments].each do |attribute|
      [nil, '', ' '].each do |value|
        order.send("#{attribute}=", value)
        order.valid?
        assert_includes order.errors[attribute],
                        I18n.t('errors.messages.blank'),
                        "attribute: #{attribute}, value: #{value}"
      end
    end
  end

  test 'should has imei minimum length error message' do
    order = Order.new(imei: '9999')
    order.valid?
    assert_includes(
      order.errors[:imei],
      I18n.t('errors.messages.too_short.other', count: Order::IMEI_MIN_LENGTH)
    )
  end

  test 'should has imei maximum length error message' do
    order = Order.new(imei: '9999999999999999999')
    order.valid?
    assert_includes(
      order.errors[:imei],
      I18n.t('errors.messages.too_long.other', count: Order::IMEI_MAX_LENGTH)
    )
  end

  test 'should has annual_price must be greater than 0 error message' do
    order = Order.new
    [0, -1, -1.1, 0.0].each do |value|
      order.annual_price = value
      order.valid?
      assert_includes order.errors[:annual_price],
                      I18n.t('errors.messages.greater_than', count: 0)
    end
  end

  test 'should has installments must be greater than 0 error message' do
    order = Order.new
    [0, -1].each do |value|
      order.installments = value
      order.valid?
      assert_includes order.errors[:installments],
                      I18n.t('errors.messages.greater_than', count: 0)
    end
  end

  test 'should has installments must be an integer error message' do
    order = Order.new
    [-1.1, 0.0, BigDecimal('123.12')].each do |value|
      order.installments = value
      order.valid?
      assert_includes order.errors[:installments],
                      I18n.t('errors.messages.not_an_integer')
    end
  end

  test 'should parse to json correctly' do
    expected = { id: 99,
                 imei: '888888888888888',
                 phone_model: 'Zenphone 2',
                 annual_price: '300.32',
                 installments: 3,
                 user: { id: 12,
                         name: 'José da Silva',
                         cpf: '123.123.123-21',
                         email: 'jo@email.com' } }

    assert_equal JSON.parse(expected.to_json),
                 JSON.parse(Order.new_from(expected).to_json)
  end

  test 'should store order and user' do
    order = Order.new(imei: '888888888888888',
                      phone_model: 'Zenphone 2',
                      annual_price: '300.32',
                      installments: 3,
                      user: User.new(
                        name: 'Rafael Moraes',
                        cpf: CPF.generate(true),
                        email: 'rafaelmoraes@email.com'
                      ))
    response = JSON.parse(order.to_json).merge(id: 22, user: { id: 19 })

    stub_request(:post, 'http://localhost:3000/orders')
      .with(body: { order: JSON.parse(order.to_json) }.to_json)
      .to_return(status: 200, body: response.to_json, headers: {})
    assert order.store
    assert_equal 22, order.id
    assert_equal 19, order.user.id
  end

  test 'should returns all orders' do
    order = Order.new(imei: '888888888888888',
                      phone_model: 'Zenphone 2',
                      annual_price: '300.32',
                      installments: 3,
                      user: User.new(
                        name: 'Rafael Moraes',
                        cpf: CPF.generate(true),
                        email: 'rafaelmoraes@email.com'
                      ))
    stub_request(:get, 'http://localhost:3000/orders')
      .to_return(status: 200, body: "{\"orders\": [#{order.to_json}]}")
    orders = Order.all
    assert_kind_of Array, orders
    assert_kind_of Order, orders.first
  end
end
