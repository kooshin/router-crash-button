#!/usr/bin/env ruby
# frozen_string_literal: true

require 'expect4r'
require_relative 'lib/dash_button'

DASH_BUTTON_MAC_ADDR  = '88:71:e5:63:aa:d5'
NETDEV                = 'enp0s25'

ROUTER_HOST           = '192.168.88.5'
ROUTER_USER           = 'cisco'
ROUTER_PASSWORD       = 'cisco'
ROUTER_ENABLE         = 'cisco'

dash_button = DashButton.new(NETDEV, DASH_BUTTON_MAC_ADDR)
puts 'Waiting for Crash Button press...'

dash_button.monitor do
  begin
    puts "#{DateTime.now} Crash Button pressed!! Force crash the Router"
    ios = Expect4r::Ios.new_telnet(
      host: ROUTER_HOST,
      user: ROUTER_USER,
      pwd:  ROUTER_PASSWORD,
      enable_password: ROUTER_ENABLE
    )
    ios.login
    ios.exp_print("test crash\rC\r1\r")
  rescue Expect4r::ExpTimeoutError, Errno::EIO => e
    puts "#{DateTime.now} Failed: #{e}"
  end
end
