# aws-watcher
A mechanism for finding nodes that have spun up and not bootstrapped to chef

The implementation is based on: https://github.com/eheydrick/aws-cleaner

This application is under active development and is not production ready, there will be rapid and breaking changes for a bit and when we are ready we will release a 1.0 and then all breaking changes will be a major version bump regardless of the % of users it breaks.

# Setup
The setup for cloudwatch should be the same as aws-cleaner other than it should use a different queue name and should be the same other than the state should be "running" rather than terminated. here is an example of the event pattern:
```json
{
  "source": [
    "aws.ec2"
  ],
  "detail-type": [
    "EC2 Instance State-change Notification"
  ],
  "detail": {
    "state": [
      "running"
    ]
  }
}
```

You will also need to have some tag that we can filter on I recommend using something like the environment name or the chef_server name.

### Installation

1. `gem install aws-watcher`

### Usage

```
Options:
  -c, --config=<s>    Path to config file (default: config.yml)
  -t, --tag=<s>       Filters events by ec2 tag. Can supply multiple values (tagName:tagValue1,tagValue2)
  -h, --help          Show this message
```

Copy the example config file `config.yml.sample` to `config.yml`
and fill in the configuration details. You will need AWS Credentials
and are strongly encouraged to use an IAM user with access limited to
the AWS CloudWatch Events SQS queue.You will need to specify the region
in the config even if you are using IAM Credentials.

The app takes a configuration file via arg `-c`. If `-c` is omitted it will look for `config.yml` file in the current directory.

Due to limitations on Cloudwatch alert filtering there is no way to support multiple chef servers in the same aws account and region without filtering on something like an aws tag. As such we decided to go a simple route and have this specified via arg `-t`. The idea is that many companies need multiple chef servers in the same aws account and in the same region but may be separated by business unit or environment.

Example use cases for aws tags:
- Single chef server for an org/business unit or per environment chef servers: `environment:dev` or `biz_unit:foo`
- Single chef server with multiple environments: `environment:prod1,prod2`
- Single chef server (possibly mixed with other groups using other CM): `chef_managed:true`



The app is started by running aws_watcher.rb and it will run until
terminated. A production install would start it with upstart or
similar.

Example Notification:

![aws-watcher](https://raw.github.com/majormoses/aws-watcher/master/example-notification.png)

### Limitations
#### Cloudwatch
There are some limitations on cloudwatch and the ability to filter an event. Even if you have multiple vpcs providing isolation per account we cant filter without some information. I decided to go with an aws tag as this provides a simple way and fits my existing deployment model. See above for usage.

#### aws-cleaner
- the notification for Hipchat will always have 'AWS Cleaner' because this is hard coded in the upstream library. I have identified where and I will create a PR to fix that once my existing PRs are merged.

In addtion please note the limitations in the upstream repository: https://github.com/eheydrick/aws-cleaner/blob/master/README.md#limitations
