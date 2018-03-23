module GeoserverMigrations
  class LayerConfig

    # attr_writer :sld, :layer_name, :feature_name, :style_name
    attr_accessor :options

    def initialize(layer_name)
      @options = {
          layer_name: layer_name
      }
    end
    
    def valid?
      # at least feature-name should be present?
      options[:feature_name].present?
    end

    def style_name(style_name=nil)
      if style_name.nil?
        @options[:style_name] || @options[:layer_name]
      else
        @options[:style_name] = style_name
      end   
    end

    def method_missing(method,*args,&block)
      # puts "LayerConfig method-missing: #{method.inspect}, #{args.inspect}"
      if [:sld, :layer_name, :feature_name, :style_name].include? method.to_sym
        if args.size > 0
          value = args.size == 1 ? args.first : args
          value = value.strip if value.is_a? String 
          @options[method.to_sym] = value
        else 
          @options[method.to_sym]
        end
      else
        super
      end
    end
  end
end