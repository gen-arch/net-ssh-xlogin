require 'net/ssh/xlogin/factory'
require 'net/ssh/telnet'
require 'net/ssh'
module Net::SSH::Xlogin
  class Connection < Net::SSH::Telnet
    attr_reader :name, :user
    def initialize(name, **opt)
      @name        = name
      @config      = Net::SSH::Xlogin.factory.get(name)
      @user        = @config.delete(:user)
      @ssh_options = @config.slice(*Net::SSH::VALID_OPTIONS, :password)
      @ssh         = Net::SSH.start(@name, @user, @ssh_options.merge(config: true))

      args         = Hash.new
      max_retry    = opt[:retry  ] || 1
      timeout      = opt[:timeout] || 10

      begin
        args['Timeout'] = timeout
        args['FailEOF'] = true
        args['Session'] = @ssh
        super(args)
      rescue => e
        retry if (max_retry -= 1) > 0
        raise e
      end
    end

    def cmd(*args)
      res = super
      res.gsub(/\e\[\d{1,3}[mK]|\e\[\d{1,3};\d{1,3}[mK]|\e\]\d{1,3};/, '')
    end
  end
end
