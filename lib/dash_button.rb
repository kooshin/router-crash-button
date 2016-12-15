# frozen_string_literal: true

require 'pcaprub'
require 'pio'

# Amazon Dash Button
class DashButton
  SNAPLENGTH      = 64
  PROMISCOUS_MODE = false
  TIMEOUT         = 0
  BPF_FILTER      = 'arp'

  attr_reader :netdev, :dash_button_mac_addr

  def initialize(netdev, dash_button_mac_addr)
    @netdev = netdev
    @dash_button_mac_addr = dash_button_mac_addr
  end

  def monitor
    pcap.each_packet do |raw_packet|
      begin
        packet = Pio::Parser.read(raw_packet.data)
        yield if dash_button_pressed?(packet)
      rescue Pio::ParseError
        next
      end
    end
  end

  private

  def pcap
    return @pcap if @pcap

    @pcap = PCAPRUB::Pcap.open_live(
      netdev,
      SNAPLENGTH,
      PROMISCOUS_MODE,
      TIMEOUT
    )
    @pcap.setfilter(BPF_FILTER)
  end

  def dash_button_pressed?(packet)
    arp_packet?(packet) && dash_button_mac_addr?(packet)
  end

  def arp_packet?(packet)
    Pio::Arp::Request == packet.class
  end

  def dash_button_mac_addr?(packet)
    dash_button_mac_addr == packet.source_mac
  end
end
