require 'yaml'

require 'net/ssh/xlogin/version'
require 'net/ssh/xlogin/factory'
require 'net/ssh/xlogin/template'

module Net::SSH::Xlogin
  class Error < StandardError; end
  class << self
    def get(name, **opts, &block)
      begin
        opts     = factory.inventory[name].merge(opts)
        type     = opts[:type]
        template = factory.templates[type]
        session  = template.build(name, **opts)

        return session unless block
        yield  session
      rescue => err
        raise Error.new(err)
      ensure
        session.close rescue nil
      end
    end

    def list(**query)
      factory.query(query)
    end

    def configure(&block)
      instance_eval(&block)
    end

    def source(*args)
      args.each do |src|
        src = case src
              when /\.y(a)?ml$/
                factory.yaml(src)
              when String
                if File.exist?(src)
                  factory.dsl(IO.read(src))
                else
                  factory.dsl(src)
                end
              when Hash
                name = src.delete(:host)
                factory.set_source(name, **src)
              end
      end
    end

    def template(*templates, **opts, &block)
      name = opts[:type]

      if block
        template = factory.templates[name] || Template.new(name)
        template.instance_eval(&block)
        factory.templates[name] = template
        return
      end

      templates = templates.map{|path| Dir.exist?(path) ? Dir.glob(File.join(path, '*.rb')) : path }.flatten
      templates.each do |path|
        name     ||= File.basename(path, '.rb').scan(/\w+/).join('_').to_sym
        text       = IO.read(path)
        template   = factory.templates[name] || Template.new(name)
        template.instance_eval(text)

        factory.templates[name] = template
      end
    end

    private
    def factory
      @factory ||= Factory.instance
    end
  end
end
