module GeoserverMigrations
  module Base

    def self.connection=(connector)
      @connection = connector
    end

    def self.connection
      @connection ||= GeoserverMigrations::APIConnector.new
    end

  end
end