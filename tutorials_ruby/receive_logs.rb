#!/usr/bin/env ruby
# encoding: utf-8

require "bunny"

conn = Bunny.new(:automatically_recover => false)
# conn = Bunny.new("amqp://guest:guest@microserver.local:5672", :automatically_recover => false)
conn.start

ch  = conn.create_channel
x   = ch.fanout("logs")
q   = ch.queue("", :exclusive => true)

q.bind(x)

puts " [*] Waiting for logs. To exit press CTRL+C"

begin
  q.subscribe(:block => true) do |delivery_info, properties, body|
    puts " [x] #{body}"
  end
rescue Interrupt => _
  ch.close
  conn.close

  exit(0)
end