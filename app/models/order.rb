# frozen_string_literal: true

class Order < ApplicationStorable
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON

  attr_accessor :id,
                :imei,
                :phone_model,
                :installments,
                :annual_price,
                :user

  IMEI_MIN_LENGTH = 15
  IMEI_MAX_LENGTH = 18

  validates :imei, :phone_model, :annual_price, :installments, presence: true
  validates :imei,
            length: { minimum: IMEI_MIN_LENGTH, maximum: IMEI_MAX_LENGTH }
  validates :annual_price, numericality: { greater_than: 0 }
  validates :installments, numericality: { greater_than: 0, only_integer: true }

  def attributes
    { id: nil,
      imei: nil,
      phone_model: nil,
      installments: nil,
      annual_price: nil,
      user: nil }
  end

  def refresh_instance!(hash)
    hash.each do |attribute, value|
      value = User.new(value) if attribute.to_s == 'user'
      send("#{attribute}=", value)
    end
  end
end
