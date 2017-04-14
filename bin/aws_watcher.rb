#!/usr/bin/env ruby
#
# Listen for AWS CloudWatch Events EC2 running events delivered via SQS
# and removes events after nodes have sucessfully bootstrapped to Chef.
# Copyright (c) 2017 Ben Abrams
# Licensed under The MIT License
#

# ensure gems are present
begin
  # aws-cleaner deps
  require 'json'
  require 'yaml'
  require 'aws-sdk-core'
  require 'chef-api'
  require 'chronic'
  require 'hipchat'
  require 'rest-client'
  require 'time'
  require 'trollop'
  require 'slack/poster'
  require 'aws_cleaner/aws_cleaner.rb'
  # aws_watcher deps
rescue LoadError => e
  raise "Missing Gems: #{e}"
end

require_relative '../lib/aws-watcher.rb'

# config file
def config(file)
  YAML.safe_load(File.read(file), [Symbol])
rescue StandardError => e
  raise "Failed to open config file: #{e}"
end

# get options
opts = Trollop.options do
  opt :config, 'Path to config file', type: :string, default: 'config.yml'
end

@config = config(opts[:config])

# initialize clients
@sqs_client = AwsCleaner::SQS.client(@config)
@chef_client = AwsCleaner::Chef.client(@config)

# start program in infinate loop
loop do
  messages = @sqs_client.receive_message(
    queue_url: @config[:sqs][:queue],
    max_number_of_messages: 10,
    visibility_timeout: 3
  ).messages

  puts "Got #{messages.size} messages"
  messages.each_with_index do |message, index|
    puts "Looking at message number #{index}"
    body = AwsCleaner.new.parse(message.body)
    id = message.receipt_handle
    now = Time.now.utc
    launch_time = Chronic.parse(body['time'])

    unless body
      AwsCleaner.new.delete_message(id, @config)
      next
    end

    @instance_id = AwsCleaner.new.process_message(body)
    chef_node = AwsCleaner::Chef.get_chef_node_name(@instance_id, @config)
    elapsed_time = now - launch_time
    p "launch_time: #{launch_time}"
    p "now: #{now}"
    # if the node exists in chef it hass bootstrapped
    # so we can delete the message
    if chef_node || !AwsWatcher::EC2.instance_alive?(@instance_id, @config)
      p "instance: #{@instance_id} has bootstrapped, removing message from queue"
      AwsCleaner.new.delete_message(id, @config)

    end
    p "instance: #{@instance_id}, launched: #{launch_time}, elapsed: #{elapsed_time}"
    # if the elapsed time is less than how long we consider
    # a 'normal' converge time that's ok we just move on and
    # wait for another pass
    if elapsed_time < @config[:bootstrap][:converged_by]
      if ENV['LOG_LEVEL'] == 'DEBUG'
        'node elaspsed time is normal'
      end
      next
    # if the elapsed time is greater than or equal then we need
    # to do something although I am not sure what yet.
    elsif elapsed_time >= @config[:bootstrap][:converged_by]
      # we want to validate that the machine is still in aws
      # and did not get terminated by something like an auto scale
      # group or someone messing around in console
      p 'node elaspsed time is too high'
      notification = "node: #{@instance_id} has not checked in, "
      notification += 'it should have converged by: '
      notification += "#{@config[:bootstrap][:converged_by]} seconds "
      notification += "and has been running since: #{launch_time}"
      AwsCleaner::Notify.notify_chat(notification, @config)
    end
  end
  sleep @config[:poll_time]
end
