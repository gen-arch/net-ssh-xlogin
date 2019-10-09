require 'singleton'

module Net::SSH::Xlogin
  class Factory
    include Singleton
    def initialize
      @inventory = Hash.new
    end

    def create(yaml)
      yaml.each do |name, info|
        name = name
        info = info.reduce({}){|h, (k, v)| h = h.merge(k.to_sym => v)}
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
