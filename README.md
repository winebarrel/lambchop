# Lambchop

It is a tool that invoke AWS Lambda function from the local machine as a normally script.

[![Gem Version](https://badge.fury.io/rb/lambchop.svg)](http://badge.fury.io/rb/lambchop)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lambchop'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lambchop

## Usage

**Terminal 1**:
```sh
$ cat test.js
#!/usr/bin/env lambchop
/*
function_name: test # default: file name without ext
runtime: nodejs     # default: nodejs
mode: event         # default: event
description: ''     # default: (empty)
timeout: 3          # default: 3
memory_size: 128    # default: 128
role: arn:aws:iam::NNNNNNNNNNNN:role/lambda_exec_role
handler: test.handler
# Handler module name is filename.
# `handler:` is `index.handler` when filename is `index.js`
*/
console.log('Loading event');

exports.handler = function(event, context) {
    console.log('value1 = ' + event.key1);
    console.log('value2 = ' + event.key2);
    console.log('value3 = ' + event.key3);
    context.done(null, 'Hello World');  // SUCCESS with message
};

$ ./test.js
(Wait event...)
```

**Terminal 2**:
```sh
$ lambchop-cat
usage: lambchop-cat <function-name>

$ lambchop-cat
$ echo '{"key1":100, "key2":200, "key3":300}' | lambchop-cat test
```

**Terminal 1**:
```sh
2014-11-23T08:06:53.212Z  xxxxxxxxxxxxxxxx  Loading event
START RequestId: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
2014-11-23T08:06:53.330Z  xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx  value1 = 100
2014-11-23T08:06:53.330Z  xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx  value3 = 300
2014-11-23T08:06:53.330Z  xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx  value2 = 200
END RequestId: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
REPORT RequestId: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx  Duration: 117.54 ms Billed Duration: 200 ms   Memory Size: 128 MB Max Memory Used: 9 MB
```

## Dump function

```sh
$ lambchop-dump
usage: lambchop-dump <function-name>

$ lambchop-dump test
#!/usr/bin/env lambchop
/*
function_name: test
runtime: nodejs
role: arn:aws:iam::NNNNNNNNNNNN:role/lambda_exec_role
handler: test.handler
mode: event
description: ''
timeout: 3
memory_size: 128
*/
console.log('Loading event');

exports.handler = function(event, context) {
    console.log('value1 = ' + event.key1);
    console.log('value2 = ' + event.key2);
    console.log('value3 = ' + event.key3);
    context.done(null, 'Hello World');  // SUCCESS with message
};
```

## Upload only

```javascript
#!/usr/bin/env lambchop -d
...
```

## Follow log only

```sh
~$ lambchop-tail
usage: lambchop-tail <function-name>

~$ lambchop-tail test
START RequestId: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
...
```

# node module path
```
.
├── lambda-script.js
└── node_modules/
```

## Demo

* https://asciinema.org/a/14158
