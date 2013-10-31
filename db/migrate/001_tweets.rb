#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

module TwitterCrawler
  class TweetSchema < ActiveRecord::Migration
    def up
      create_table :tweets do |t|
        t.integer  :status_id
        t.datetime :created_at
        t.text     :text
        t.boolean  :retweeted, :default => false
        t.boolean  :alived, :default => false
      end
    end

    def down
      drop_table :twitter
    end
  end
end

