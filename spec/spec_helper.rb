require 'rubygems'
require 'rails/all'
require 'erbac'
require "bundler/setup"

Erbac.configure

load File.dirname(__FILE__) + "/support/adapters/active_record.rb"
load File.dirname(__FILE__) + '/support/data.rb'
