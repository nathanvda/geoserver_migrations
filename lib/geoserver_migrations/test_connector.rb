module GeoserverMigrations
  class TestConnector

    attr_accessor :collected_actions

    def initialize
      @collected_actions = {}
    end

    def execute(layer_configs, options={})
      collected_actions.merge!(layer_configs)
    end

  end
end