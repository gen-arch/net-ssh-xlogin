require 'net/ssh'
require 'net/ssh/telnet'
require 'net/ssh/xlogin/factory'

module Net::SSH::Xlogin
  class Connection < Net::SSH::Telnet
    ESCAPE_CHARACTER = [/\e\]\d{1,3};/,/\e\[\d{1,3}[mK]/,/\e\[\d{1,3};\d{1,3}[mK]/, /\e\]\d{1,3};/]

    attr_reader :name
    def initialize(template, name, **opts)
      @name     = name
      @config   = opts

      log       = @config[:log] || @config[:output_log]
      info      = @config[:uri]
      max_retry = @config[:max_retry] || 1
      @host     = info.host
      @user     = info.user
      @pass     = info.password

      begin
        args = Hash.new
        args["Output_log"]  = log if log
        args["Dump_log"]    = @config[:dump_log]   if @config[:dump_log]
        args["Prompt"]      = @config[:prompt]     || template.prompt_patten
        args["Timeout"]     = @config[:timeout]    || 10
        args["Waittime"]    = @config[:waittime]   || 0
        args["Terminator"]  = @config[:terminator] || LF
        args["Binmode"]     = @config[:binmode]    || false
        args["PTYOptions"]  = @config[:ptyoptions] || {}

        if @config[:proxy]
          args["Proxy"]     = @config[:proxy]
        else
          ssh_options       = @config.slice(*Net::SSH::VALID_OPTIONS)
          args['Session']   = Net::SSH.start(nil, nil, ssh_options)
        end


        super(args)
      rescue => e
        retry if (max_retry -= 1) > 0
        raise e
      end
    end

    def cmd(*args)
      res = super
      res.gsub(/[[:cntrl:]]/, '') if @config[:escape] == true
      res
    end
  end
end
