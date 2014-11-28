require 'erb'
require 'json'
require 'open-uri'
require 'yaml'

require 'aws-sdk-core'
require 'diffy'
require 'zip'

module Lambchop; end

require 'lambchop/cat'
require 'lambchop/client'
require 'lambchop/diff'
require 'lambchop/dump'
require 'lambchop/tail'
require 'lambchop/utils'
require 'lambchop/watch_dog'
require 'lambchop/version'
