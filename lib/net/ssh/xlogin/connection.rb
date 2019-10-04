require 'net/ssh/xlogin/factory'
require 'net/ssh'
module Net::SSH::Xlogin
  class Connection
    attr_reader :name, :user
    def initialize(name)
      @name        = name
      @config      = Net::SSH::Xlogin.factory.get(name)
      @user        = @config.delete(:user)
      @ssh_options = @config.slice(*Net::SSH::VALID_OPTIONS, :password)
      @session     = Net::SSH.start(name, user, @ssh_options.merge(config: true))
    end

    def cmd(str)
      buf = @session.exec! str
    end

    def crontab
      str = "crontab -l"
      str = "crontab -l -u #{@config[:cron_user]}" if @config[:cron_user]

      cmd(str)
    end
  end
end
