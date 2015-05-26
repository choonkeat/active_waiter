require "active_waiter/engine"
require "active_waiter/configuration"
require "active_waiter/job"
require "active_waiter/enumerable_job"

module ActiveWaiter
  class << self
    def next_uuid
      SecureRandom.uuid
    end

    def enqueue(klass, *arguments)
      next_uuid.tap do |uid|
        ActiveWaiter.write(uid, {})
        klass.perform_later({ uid: uid }, *arguments)
      end
    end

    def write(uid, value)
      Rails.cache.write("active_waiter:#{uid}", value)
    end

    def read(uid)
      Rails.cache.read("active_waiter:#{uid}")
    end
  end
end
