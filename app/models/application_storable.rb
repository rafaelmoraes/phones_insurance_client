# frozen_string_literal: true

class ApplicationStorable
  def store
    return true if id.present?
    return false if invalid?

    send_to_storage
  end

  def self.search(query_hash)
    return nil if query_hash.empty?

    hash = storage.get("#{storage_collection_name}/search", query_hash)
    return nil unless hash

    new_from(hash[storage_item_name])
  end

  def self.all
    storage.get(storage_collection_name)[storage_collection_name].map do |item|
      new_from(item)
    end
  end

  def self.new_from(hash)
    object = new
    object.refresh_instance!(hash)
    object
  end

  def refresh_instance!(hash)
    hash.each { |attribute, value| send("#{attribute}=", value) }
  end

  def self.storage_collection_name
    @storage_collection_name ||= storage_item_name.pluralize
  end

  def self.storage_item_name
    @storage_item_name ||= to_s.underscore
  end

  def self.storage
    @storage ||= Warehouse.new
  end

  private

  def send_to_storage
    storage.add(storage_collection_name, storage_item_name => self)
    return parse_storage_errors(storage.errors) unless storage.success?

    parse_storage_response(storage.response)
    true
  end

  def remove_root_json(hash)
    root = self.class.to_s.underscore
    return hash unless hash.key? root

    hash[root]
  end

  def parse_storage_response(response)
    instance_hash = remove_root_json(response)
    refresh_instance!(instance_hash)
  end

  def parse_storage_errors(errors)
    add_error_messages(errors)
    false
  end

  def add_error_messages(messages)
    messages.each { |message| errors.add(:base, message) }
  end

  def storage
    @storage ||= Warehouse.new
  end

  def storage_collection_name
    self.class.storage_collection_name
  end

  def storage_item_name
    self.class.storage_item_name
  end
end
