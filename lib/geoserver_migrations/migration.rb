module GeoserverMigrations
  class Migration

    attr_accessor :name, :version, :assets_path

    def initialize(name = self.class.name, version = nil)
      @name       = name
      @version    = version
      @connection = nil
      @layers_to_create = {}
      @layers_to_delete = []
      @styles_to_delete = []
      @ordered_actions_to_take = []
      @assets_path = nil
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
        GeoserverMigrations::Base.connection.execute(@ordered_actions_to_take, direction)
      end

      operation = direction == :up ? 'migrated' : 'reverted'
      announce "#{operation} (%.4fs)" % time.real; write
    end


    def add_resource(resource_name)
      # translate to full file-name and raise error if not exists?

      full_resource_name = File.join(File.expand_path(self.assets_path), resource_name )

      raise StandardError.new("File #{full_resource_name} not found!") unless File.exists?(full_resource_name)

      @ordered_actions_to_take << {action: :add_resource, params: {name: full_resource_name }}
    end

    def create_layer(layer_name, &block)
      layer_config = GeoserverMigrations::LayerConfig.new(layer_name)
      layer_config.instance_eval(&block) if block_given?
      if layer_config.valid?
        @layers_to_create[layer_name] = layer_config
        @ordered_actions_to_take << {action: :create_layer, params: {name: layer_name, layer_config: layer_config}}
      end
    end

    def create_layergroup(layer_name, &block)
      layergroup_config = GeoserverMigrations::LayergroupConfig.new(layer_name)
      layergroup_config.instance_eval(&block) if block_given?
      if layergroup_config.valid?
        @layers_to_create[layer_name] = layergroup_config
        @ordered_actions_to_take << {action: :create_layergroup, params: {name: layer_name, layer_config: layergroup_config}}
      end
    end

    def update_style(layer_name, &block)
      layer_config = GeoserverMigrations::LayerConfig.new(layer_name, true)
      layer_config.instance_eval(&block) if block_given?
      if layer_config.valid?
        @ordered_actions_to_take << {action: :update_style, params: {name: layer_name, layer_config: layer_config}}
      end
    end

    def delete_layer(layer_name)
      @layers_to_delete << layer_name
      @ordered_actions_to_take << {action: :delete_layer, params: {name: layer_name }}
    end

    def delete_layergroup(layer_name)
      @layers_to_delete << layer_name
      @ordered_actions_to_take << {action: :delete_layergroup, params: {name: layer_name }}
    end

    def delete_style(style_name)
      @styles_to_delete << style_name
      @ordered_actions_to_take << {action: :delete_style, params: {name: style_name }}
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