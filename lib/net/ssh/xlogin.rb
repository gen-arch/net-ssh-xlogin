require 'yaml'

require 'net/ssh/xlogin/version'
require 'net/ssh/xlogin/factory'
require 'net/ssh/xlogin/connection'

module Net::SSH::Xlogin
  class Error < StandardError; end
  class << self
    def get(name)
      session = Connection.new(name)
    end

    def configure(&bk)
      instance_eval(&bk)
    end

    def config(file)
      yaml = case file
             when /\.y(a)?ml$/
               raise Error, 'not cofnig file' unless File.exist?(file)
               YAML.load_file(file)
             when String
               YAML.load(YAML.dump(file))
             when Hash
               file
             when YAML
               YAML.dump(file)
             end
      factory.create(yaml)
    end

    def factory
      @factory ||= Factory.instance
    end

  end
end
