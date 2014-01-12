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

ttl = 2
begin
  Twitter.user_timeline(:me, :count => 200).each do |tweet|
    if AutoTweetDelete::Tweet.find_by_status_id(tweet['id']).nil? then
      AutoTweetDelete::Tweet.create(status_id:  tweet['id'],
                                    created_at: tweet['created_at'],
                                    text:       tweet['text'])
      puts "added #{tweet.id}"
    end
  end
rescue => e
  sleep 10
  ttl -= 1
  retry if ttl > 0
end
