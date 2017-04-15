# Changelog

### Unreleased

#### 0.3.1
Just accidental issue with pre-release no real changes.

#### 0.3.0
Breaking Changes
- requires the use of an arg to specify one or more values for an ec2 tag to filter on `-t tagName:TagVal1,TagVal2`. This is to allow multiple chef servers in the same aws account in the same region without creating false positives. This is do to the way CloudWatch event filtering works.

#### 0.2.0
- improving the notification message to be more user friendly
- improving logic to be more user friendly

#### 0.1.0
- initial working version.
