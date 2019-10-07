require 'singleton'

module Net::SSH::Xlogin
  class Factory
    include Singleton
    def initialize
      @inventory = Hash.new
    end

    def create(yaml)
      yaml.each do |name, info|
        name = name.to_sym
        info = info.reduce({}){|h, (k, v)| h = h.merge(k.sym => v)}
        set name, info
      end
    end

    def set(name, args)
      @inventory[name] = args
    end

    def get(name)
      @inventory[name]
    end

  end
end
