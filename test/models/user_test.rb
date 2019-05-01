# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'should has these attribute accessors' do
    order = User.new
    %i[id name cpf email].each do |attribute|
      assert_respond_to order, attribute
      assert_respond_to order, "#{attribute}="
    end
  end

  test 'should #serializable_hash returns the correct hash' do
    expected = { id: nil, name: nil, cpf: nil, email: nil }

    assert_equal expected, User.new.serializable_hash
  end

  test 'should not store' do
    assert_not User.new.store
  end

  test 'should has blank attribute error message' do
    user = User.new
    %i[name email cpf].each do |attribute|
      [nil, ''].each do |value|
        user.send("#{attribute}=", value)
        user.valid?
        assert_includes user.errors[attribute],
                        I18n.t('errors.messages.blank'),
                        "attribute: #{attribute}, value: #{value}"
      end
    end
  end

  test 'should has a cpf invalid error' do
    user = User.new(cpf: '999.999.99-99')
    user.valid?
    assert_includes user.errors[:cpf], I18n.t('errors.messages.invalid')
  end

  test 'should has a email invalid error' do
    user = User.new(email: 'invalid@ email')
    user.valid?
    assert_includes user.errors[:email], I18n.t('errors.messages.invalid')
  end

  test '#cpf_valid? should returns false' do
    user = User.new
    [nil, '', '999'].each do |value|
      user.cpf = value
      assert_not user.cpf_valid?, "cpf is #{value}"
    end
  end

  test 'should parse to json correctly' do
    expected = { id: 12,
                 name: 'José da Silva',
                 cpf: '123.123.123-21',
                 email: 'jo@email.com' }

    assert_equal JSON.parse(expected.to_json),
                 JSON.parse(User.new(expected).to_json)
  end

  test 'should store user' do
    user = User.new(name: 'Rafael Moraes',
                    cpf: CPF.generate(true),
                    email: 'rafaelmoraes@email.com')
    response = JSON.parse(user.to_json).merge(user: { id: 88 })

    stub_request(:post, 'http://localhost:3000/users')
      .with(body: { user: JSON.parse(user.to_json) }.to_json)
      .to_return(status: 200, body: response.to_json, headers: {})
    assert user.store
    assert_equal 88, user.id
  end

  test 'should not found an user with this cpf' do
    user = User.new(name: 'Rafael Moraes',
                    cpf: CPF.generate(true),
                    email: 'rafaelmoraes@email.com')
    response = { user: user.serializable_hash.merge(id: 87) }

    stub_request(:get, "http://localhost:3000/users/search?cpf=#{user.cpf}")
      .to_return(status: 200, body: response.to_json)

    assert_kind_of User, User.search(cpf: user.cpf)
  end

  test 'should found an user with this cpf' do
    stub_request(:get, 'http://localhost:3000/users/search?cpf=820.520.762-39')
      .to_return(status: 404)

    assert_nil User.search(cpf: '820.520.762-39')
  end

  test 'should returns all users' do
    stub_request(:get, 'http://localhost:3000/users')
      .to_return(status: 200, body: '{"users": []}')
    assert_kind_of Array, User.all
  end

  test 'should not store the user and returns errors' do
    stub_request(:post, 'http://localhost:3000/users')
      .to_return(status: 400, body: '{"errors": ["Name can\'t be blank"]}')
    user = User.new
    def user.invalid?
      false
    end
    assert_not user.store
    assert_kind_of Array, user.errors.full_messages
    assert_equal "Name can't be blank", user.errors.full_messages.first
  end

  test 'should has an 500 Internal Error' do
    stub_request(:post, 'http://localhost:3000/users')
      .to_return(status: 500, body: '')
    user = User.new
    def user.invalid?
      false
    end
    assert_not user.store
    assert_kind_of Array, user.errors.full_messages
    assert_equal '500 - Internal error', user.errors.full_messages.first
  end
end
