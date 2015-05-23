require "waiter/engine"
require "waiter/job"

module Waiter
  class << self
    def next_uuid
      SecureRandom.uuid
    end

    def enqueue(klass, *arguments)
      next_uuid.tap do |uid|
        Waiter.write(uid, {})
        klass.perform_later({ uid: uid }, *arguments)
      end
    end

    def write(uid, value)
      Rails.cache.write("waiter:#{uid}", value)
    end

    def read(uid)
      Rails.cache.read("waiter:#{uid}")
    end
  end
end
