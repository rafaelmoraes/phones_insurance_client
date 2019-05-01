# frozen_string_literal: true

class User < ApplicationStorable
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON

  attr_accessor :id, :name, :cpf, :email

  validates :name, :email, :cpf, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :cpf do
    errors.add(:cpf, :invalid) if cpf.present? && !cpf_valid?
  end

  def cpf_valid?
    return false if cpf.blank?

    CPF.valid?(cpf)
  end

  def attributes
    { id: nil, name: nil, cpf: nil, email: nil }
  end
end
