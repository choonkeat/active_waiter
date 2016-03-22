module ActiveWaiter
  class Store
    def write(uid, value)
      Rails.cache.write("active_waiter:#{uid}", value)
    end

    def read(uid)
      Rails.cache.read("active_waiter:#{uid}")
    end
  end
end
