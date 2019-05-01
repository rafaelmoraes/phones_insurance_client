# frozen_string_literal: true

class OrdersController < ApplicationController
  def index
    @orders = Order.all
  end

  def new
    @order = Order.new(user: User.new)
  end

  def create
    @order = Order.new_from(order_params)
    return render :new unless @order.store

    redirect_to @order, notice: 'Order was successfully created.'
  end

  private

  def order_params
    params.require(:order).permit(
      :id,
      :imei,
      :phone_model,
      :installments,
      :annual_price,
      user: %i[id cpf name email]
    )
  end
end
