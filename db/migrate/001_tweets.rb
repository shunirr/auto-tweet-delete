#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

class Tweets < ActiveRecord::Migration
  def up
    create_table :tweets do |t|
      t.integer  :status_id
      t.datetime :created_at
      t.text     :text
      t.boolean  :alived, :default => false
    end
  end

  def down
    drop_table :twitter
  end
end
