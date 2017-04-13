# main aws_watcher lib
class AwsWatcher
  require 'aws_cleaner/aws_cleaner.rb'
  module Chef
    include AwsCleaner::Chef
  end

  module SQS
    include AwsCleaner::SQS
  end

  module EC2
    def self.client(config)
      Aws::EC2::Client.new(config[:aws])
    end

    def self.instance_alive?(id, config)
      AwsWatcher::EC2.client(config).describe_instance_attribute(
        attribute: 'instanceType',
        instance_id: id.to_s
      )
      true
    rescue Aws::EC2::Errors::InvalidInstanceIDNotFound => e
      p "instance: #{id} was not found."
      if ENV['LOG_LEVEL'] == 'DEBUG'
        p e
      end
      false
    end
  end

  module Notify
    include AwsCleaner::Notify
  end
end
