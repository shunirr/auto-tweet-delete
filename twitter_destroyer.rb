#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

$:.unshift './lib', './' 

require 'pit'
require 'twitter'
require 'active_record'
require 'auto_tweet_delete'

ActiveRecord::Base.configurations = YAML.load(File.open('database.yml'))
ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations)

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

def expired?(created_at)
  expire_time = ((Time.now - stored_tweet.created_at) / 3600).to_i
  expire_time >= 1
end

Twitter.user_timeline(:me).each do |tweet|
  stored_tweet = AutoTweetDelete::Tweet.find_by_status_id(tweet['id'])
  unless stored_tweet.nil? and stored_tweet['alived']
    if expired?(stored_tweet.created_at)
      Twitter.status_destroy(tweet['id'])
      puts "deleted #{stored_tweet['status_id']}"
      sleep 10
    end
  end
end

