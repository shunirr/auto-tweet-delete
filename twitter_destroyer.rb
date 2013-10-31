#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'pit'
require 'twitter'
require 'active_record'
require 'model/tweet'

ActiveRecord::Base.establish_connection(
  adapter:  "sqlite3",
  database: "db/tweets.sqlite"
)

pit = Pit.get("twitter", :require => {
  'consumer_key'        => "YOUR_CONSUMER_KEY",
  'consumer_secret'     => "YOUR_CONSUMER_SECRET",
  'access_token'        => "YOUR_ACCESS_TOKEN",
  'access_token_secret' => "YOUR_ACCESS_SECRET"
})

Twitter.configure do |config|
  config.consumer_key       = pit['consumer_key']
  config.consumer_secret    = pit['consumer_secret']
  config.oauth_token        = pit['access_token']
  config.oauth_token_secret = pit['access_token_secret']
end

Twitter.user_timeline(:me).each do |tweet|
  stored_tweet = TwitterCrawler::Tweet.find_by_status_id(tweet['id'])
  unless stored_tweet.nil? and stored_tweet['alived']
    Twitter.status_destroy(tweet['id'])
    puts "deleted #{stored_tweet['status_id']}"
  end
end

