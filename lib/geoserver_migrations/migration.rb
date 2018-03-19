module GeoserverMigrations
  class Migration

    attr_accessor :name, :version

    def initialize(name = self.class.name, version = nil)
      @name       = name
      @version    = version
      @connection = nil
      @layers_to_create = {}
    end

    def migrate(direction = :up)
      return unless [:up, :down].include?(direction)

      case direction
        when :up   then announce "migrating"
        when :down then announce "reverting"
      end

      time = Benchmark.measure do
        # collect configuration
        run

        # puts @layers_to_create.inspect

        # create configured layers
        GeoserverMigrations::Base.connection.execute(@layers_to_create, direction)
      end

      operation = direction == :up ? 'migrated' : 'reverted'
      announce "#{operation} (%.4fs)" % time.real; write
    end


    def create_layer(layer_name, &block)
      layer_config = GeoserverMigrations::LayerConfig.new(layer_name)
      layer_config.instance_eval(&block) if block_given?
      @layers_to_create[layer_name] = layer_config if layer_config.valid?
    end

    def write(text = "")
      puts(text) unless Rails.env.test? 
    end

    def announce(message)
      text = "#{version} #{name}: #{message}"
      length = [0, 75 - text.length].max
      write "== %s %s" % [text, "=" * length]
    end

    def say(message, subitem = false)
      write "#{subitem ? "   ->" : "--"} #{message}"
    end

    def say_with_time(message)
      say(message)
      result = nil
      time = Benchmark.measure { result = yield }
      say "%.4fs" % time.real, :subitem
      say("#{result} rows", :subitem) if result.is_a?(Integer)
      result
    end

  end
end