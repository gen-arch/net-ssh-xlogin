require 'net/ssh/xlogin/connection'

module Net::SSH::Xlogin
  class Template

    DEFAULT_TIMEOUT  = 10
    DEFAULT_PROMPT   = /[$%#>] ?\z/n
    RESERVED_METHODS = %i( login logout enable disable delegate )

    attr_reader :methods
    attr_reader :prompts

    def initialize(name)
      @name    = name
      @prompts = Array.new
      @methods = Hash.new
    end

    def prompt(expect = nil, &block)
      return [[DEFAULT_PROMPT, nil]] if expect.nil? && @prompts.empty?
      @prompts << [Regexp.new(expect.to_s), block] if expect
      @prompts
    end

    def prompt_patten
      Regexp.union(@prompts.map(&:first))
    end

    def bind(name, &block)
      @methods[name] = block
    end

    def build(name, **opts)
      klass = Class.new(Net::SSH::Xlogin.const_get('Connection'))
      klass.class_exec(self) do |template|
        template.methods.each {|name, block| define_method(name, &block) }
      end
      klass.new(self, name, **opts)
    end

    def method_missing(name, *, &block)
      super unless RESERVED_METHODS.include?(name)
      bind(name) { |*args| instance_exec(*args, &block) }
    end

  end
end
