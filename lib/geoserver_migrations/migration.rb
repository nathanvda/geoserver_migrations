module GeoserverMigrations
  class Migration

    attr_accessor :name, :version

    def initialize(name = self.class.name, version = nil)
      @name       = name
      @version    = version
      @connection = nil
      @layer_to_create = {}
    end

    def migrate
      announce "migrating"

      time = nil
      time = Benchmark.measure do
        # collect configuration
        run

        # create configured layers
        puts @layers_to_create.inspect
      end

      announce "migrated (%.4fs)" % time.real; write
    end


    def create_layer(layer_name, &block)
      layer_config = LayerConfig.new
      layer_config.instance_eval(&block) if block_given?
      @layers_to_create[layer_name] = layer_config if layer_config.valid?
    end

    def write(text = "")
      puts(text) #if verbose
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