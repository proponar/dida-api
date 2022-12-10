require "active_storage/service/disk_service"
module ActiveStorage
  class Service::ForceProtocolDiskService < Service::DiskService
    def url(key, *options)
      super(key, *options).gsub /http(s)?:/, 'https:'
    end
  end
end
