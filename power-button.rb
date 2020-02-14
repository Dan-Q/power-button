#!/usr/bin/env ruby
require 'socket'
require 'json'
require 'digest/sha2'

VERSION = 1
MAX_AGE = 30 # seconds; mitigates replay attacks
udp = UDPSocket.new

def sign(payload, key, time = Time.now.utc.to_i.to_s)
  time + ':' + Digest::SHA256.hexdigest("#{time}:#{key}:#{payload}")
end

def verify(payload, key, full_signature)
now = Time.now.utc.to_i
	return false unless payload && full_signature
	timestamp, signature = full_signature.split(':', 2)
	return false unless timestamp && signature
	return false unless now < (timestamp.to_i + MAX_AGE)
	valid_signature = sign(payload, key, timestamp)
	valid_signature == full_signature
end

if (ARGV[0] == 'listen') && (key = ARGV[1]) && (port = ARGV[2]) && ((command = ARGV[3...].join(' ')) != '')
	# listen
	udp.bind '0.0.0.0', port
	# repeatedly
	loop do
		# receive message
		message, ip = udp.recvfrom(5000)
		message_contents = JSON.parse message
		# verify signature (discard invalid messages)
		next unless verify(payload_encoded = message_contents['payload'], key, message_contents['signature'])
		payload = JSON.parse(payload_encoded)
		if payload['command'] == 'exec'
			# execute the pre-stored command
			system command
		end
	end
elsif (ARGV[0] == 'control') && (key = ARGV[1]) && (port = ARGV[2]) && ((targets = ARGV[3...]).length > 0)
	# repeatedly
	loop do
		# wait for enter key
		STDIN::gets
		# send message
		payload = JSON.dump({ 'command' => 'exec', 'version' => VERSION })
		signature = sign(payload, key)
		message = { 'payload' => payload, 'signature' => signature }
		targets.each do |target|
			udp.send JSON.dump(message), 0, target, port
		end
	end
else
	puts "Syntax: ./power-button.rb  listen [secretkey] [port] [command]\n#{' '*26}control [secretkey] [port] [target] <targets...>"
end
