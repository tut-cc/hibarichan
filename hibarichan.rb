#!/bin/ruby

require 'twitter'
require 'yaml'
require './markov'

module Hibarichan
  class Hibarichan
    def initialize(setting_file)
      # YAMLを読む
      settings = YAML.load_file(setting_file)

      # マルコフ連鎖による文章生成器の作成
      @markov = Markov.new(settings['yahoo'], './knowledge.dat')

      # Streaming Client作成
      @stream = Twitter::Streaming::Client.new(settings['twitter'])

      # REST Client作成
      @rest = Twitter::REST::Client.new(settings['twitter'])
    end

    def update(tweet)
      @rest.update(tweet)
      puts [tweet, Time.now, 'by me'].join(' ')
    end

    def push_analyzed(str)
      puts str.collect{|a| a[0]}.join('/')
    end

    def run
      user_id = @rest.user.id

      @stream.user do |object|
        case object
        when Twitter::Tweet
          if object.retweeted_tweet?
            # リツイートである
          elsif object.in_reply_to_user_id == user_id
            # 自分宛のツイートである
          else
            # その他のツイートである
            puts [object.text, Time.now, 'by', object.source].join(' ')
          end
        when Twitter::DirectMessage
        when Twitter::Streaming::DeletedTweet
        when Twitter::Streaming::Event
        when Twitter::Streaming::FriendList
        when Twitter::Streaming::StallWarning
        end
      end
    end
  end
end

# ディレクトリの移動
Dir.chdir(File.dirname(File.expand_path(__FILE__)))

# インスタンスの生成
hibarichan = Hibarichan::Hibarichan.new('settings.yaml')

# run
hibarichan.run
