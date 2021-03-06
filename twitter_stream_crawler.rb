#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

$:.unshift './lib', './'

require 'pit'
require 'twitter'
require 'tweetstream'
require 'active_record'
require 'auto_tweet_delete'

# tweetstream のバグを回避
module EventMachine
  module Twitter
    class Connection < EM::Connection
      public :on_headers_complete, :on_body
    end
  end
end

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

TweetStream.configure do |config|
  config.consumer_key       = pit['consumer_key']
  config.consumer_secret    = pit['consumer_secret']
  config.oauth_token        = pit['access_token']
  config.oauth_token_secret = pit['access_token_secret']
  config.auth_method        = :oauth
end

me = Twitter.user

TweetStream::Client.new.userstream do |tweet|
  next unless tweet.user.id == me.id
  if AutoTweetDelete::Tweet.find_by_status_id(tweet['id']).nil? then
    AutoTweetDelete::Tweet.create(status_id:  tweet['id'],
                                  created_at: tweet['created_at'],
                                  text:       tweet['text'])
    puts "added #{tweet.id}"
  end
end

