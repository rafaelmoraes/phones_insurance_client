# frozen_string_literal: true

class Warehouse
  URL_BASE = 'http://localhost:3000'
  HEADER = { content_type: :json, accept: :json }.freeze

  attr_reader :response, :errors

  def add(collection, serializable)
    rest_client[collection].post(serializable.to_json) do |response|
      parse_response(response)
    end
  end

  def get(collection, hash = {})
    hash = { params: hash } if hash.any?
    rest_client[collection].get(hash) do |response|
      parse_response(response)
    end
  end

  def success?
    @success
  end

  private

  def parse_body(response_body)
    JSON.parse(response_body)
  end

  def parse_response(response)
    case response.code
    when 200, 201
      parse_success_response(response)
    when 400
      parse_error_response(response)
    when 500
      parse_internal_error
    end
  end

  def parse_success_response(response)
    @success = true
    @response = parse_body(response)
  end

  def parse_error_response(response)
    @success = false
    @errors = parse_body(response)['errors'] if response.present?
  end

  def parse_internal_error
    @success = false
    @errors = ['500 - Internal error']
  end

  def rest_client
    @rest_client ||= RestClient::Resource.new(URL_BASE, headers: HEADER)
  end
end
