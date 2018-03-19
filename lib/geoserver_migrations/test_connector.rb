module GeoserverMigrations
  class TestConnector

    attr_accessor :collected_actions

    def initialize
      @collected_actions = {}
    end

    def execute(layer_configs, direction=:up, options={})
      collected_actions.merge!(direction => layer_configs)
    end

  end
end