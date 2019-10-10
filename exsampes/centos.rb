# exsample template file
#
# - usage
# Net::SSH::Xlogin.configure do
#   template 'centos7.rb'
# end


prompt(/[$%#>] ?\z/n)

bind(:iplist) do
  cmd('ipconfig')
end
