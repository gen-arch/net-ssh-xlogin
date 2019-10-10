require 'singleton'
require 'uri'

module Net::SSH::Xlogin
  class Factory
    include Singleton
    attr_accessor :inventory
    attr_accessor :templates

    def initialize
      @inventory = Hash.new
      @templates = Hash.new
    end

    def set_source(name, **args)
      @inventory[name] = args
    end

    def set_template(name, klass)
      @templates[name] = klass
    end

    def yaml(file)
      raise Error, 'not cofnig file' unless File.exist?(file)
      conf = YAML.load_file(file)
      conf = conf.inject({}){|h, (k,v)| h = h.merge(k.sym => v) }
      conf = conf.delete(:host)
      factory.source_set(name, **conf)
    end

    def dsl(str)
      instance_eval(str)
    end

    def method_missing(method, *args, **options)
      super unless args.size == 2

      name           = args.shift
      uri            = URI.parse(args.shift)
      options[:type]       = method
      options[:uri]        = uri
      options[:host_name]  = uri.host
      options[:user]       = uri.user
      options[:password]   = uri.password


      set_source(name, **options)
    end
  end
end
