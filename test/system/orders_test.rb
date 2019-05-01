# frozen_string_literal: true

require 'application_system_test_case'

class OrdersTest < ApplicationSystemTestCase
  test 'visiting the index' do
    visit orders_url
    assert_selector 'h1', text: 'Orders'
    assert_selector 'a', text: 'New Order'
  end

  test 'creating a Order' do
    visit orders_url

    click_on 'New Order'

    assert_text 'All Orders'
    assert_selector 'h1', text: 'New Order'

    fill_in 'Cpf', with: CPF.generate(true)
    fill_in 'Name', with: 'João Trabalhador'
    fill_in 'Email', with: 'jao@email.com'
    fill_in 'Phone model', with: 'Mokia caixão'
    fill_in 'Imei', with: '145478-98-543870-1'
    fill_in 'Annual price', with: '100.10'
    fill_in 'Installments', with: 3

    click_on 'Create Order'

    assert_text 'Order was successfully created'
  end
end
