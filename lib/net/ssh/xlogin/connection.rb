require 'net/ssh'
require 'net/ssh/telnet'
require 'net/ssh/gateway'
require 'net/ssh/xlogin/factory'

module Net::SSH::Xlogin
  class Connection < Net::SSH::Telnet

    attr_reader :name

    def initialize(template, name, **opts)
      @name     = name
      @options  = opts

      log       = @options[:log] || @options[:output_log]
      max_retry = @options[:max_retry] || 1

      @options[:timeout]   ||= template.timeout
      @options[:host_name] ||= name

      begin
        args = Hash.new
        args["Output_log"]  = log if log
        args["Dump_log"]    = @options[:dump_log]   if @options[:dump_log]
        args["Prompt"]      = @options[:prompt]     || template.prompt_patten
        args["Timeout"]     = @options[:timeout]    || 10
        args["Waittime"]    = @options[:waittime]   || 0
        args["Terminator"]  = @options[:terminator] || LF
        args["Binmode"]     = @options[:binmode]    || false
        args["PTYOptions"]  = @options[:ptyoptions] || {}

        if @options[:relay]
          relay             = @options[:relay]
          info              = Factory.instance.inventory[relay]
          @options[:port]   = Net::SSH::Gateway.new(relay, nil , info)
        end

        if @options[:proxy]
          args["Host"]      = @options[:host_name]
          args["Port"]      = @options[:port]
          args["Username"]  = @options[:user]
          args["Password"]  = @options[:password]
          args["Proxy"]     = @options[:proxy]
        else
          ssh_options       = @options.slice(*Net::SSH::VALID_OPTIONS)
          ssh_options       = @options[:host] unless @options[:host_name]
          args['Session']   = Net::SSH.start(name, nil, ssh_options)
        end

        super(args)
      rescue => e
        retry if (max_retry -= 1) > 0
        raise e
      end
    end
  end
end
