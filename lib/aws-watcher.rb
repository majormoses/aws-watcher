# main aws_watcher lib
class AwsWatcher
  require 'aws_cleaner/aws_cleaner.rb'
  module Chef
    include AwsCleaner::Chef
    def self.registered?(instance_id, config)
      chef = AwsCleaner::Chef.client(config)
      results = chef.search.query(:node, "ec2_instance_id:#{instance_id} OR chef_provisioning_reference_server_id:#{instance_id}")
      if results.rows.empty?
        false
      else
        true
      end
    end
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

    def self.tag_matches?(id, tag, values, config)
      instances = AwsWatcher::EC2.client(config).describe_instances(
        instance_ids: [id],
        filters: [
          {
            name: "tag:#{tag}",
            values: values.to_a
          }
        ]
      )
      if instances.reservations.empty?
        false
      else
        true
      end
    end
  end

  module Notify
    include AwsCleaner::Notify
  end
end
