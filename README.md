# aws-watcher
A mechanism for finding nodes that have spun up and not bootstrapped to chef

The implementation is based on: https://github.com/eheydrick/aws-cleaner


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

### Installation

1. `gem install aws-watcher`

### Usage

```
Options:
  -c, --config=<s>    Path to config file (default: config.yml)
  -h, --help          Show this message
```

Copy the example config file `config.yml.sample` to `config.yml`
and fill in the configuration details. You will need AWS Credentials
and are strongly encouraged to use an IAM user with access limited to
the AWS CloudWatch Events SQS queue.You will need to specify the region
in the config even if you are using IAM Credentials.

The app takes one arg '-c' that points at the config file. If -c is
omitted it will look for the config file in the current directory.

The app is started by running aws_watcher.rb and it will run until
terminated. A production install would start it with upstart or
similar.

Example Notification:

![aws-watcher](https://raw.github.com/majormoses/aws-watcher/master/example-notification.png)

### Limitations

None that I am aware of other than those specified in aws-cleaner which used for its simple libraries to accomplish similar tasks: https://github.com/eheydrick/aws-cleaner/blob/master/README.md#limitations
