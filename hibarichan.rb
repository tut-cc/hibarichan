#!/bin/ruby

require 'twitter'
require 'yaml'
require './markov'
require './plugins/speech_center'
require 'pp'

module Hibarichan
  class Hibarichan
    def initialize(setting_file)
      # YAMLを読む
      settings = YAML.load_file(setting_file)

      # Streaming Client作成
      @stream = Twitter::Streaming::Client.new(settings['twitter'])

      # REST Client作成
      @rest = Twitter::REST::Client.new(settings['twitter'])

      # 文章生成器作成
      @markov = Markov.new(settings['yahoo'], './knowledge.dat')

      # Speech Center作成
      #@scenter = SpeechCenter.new(@markov)
    end

    def update(tweet)
      # @rest.update(tweet)
      puts tweet
    end

    def run
      # 自分のユーザID
      user_id = @rest.user.id

      @stream.user do |object|
        case object
        when Twitter::Tweet
          if object.retweeted_tweet?
            # 誰かのリツイートを受信した
          elsif object.in_reply_to_user_id == user_id
            # 自分宛のツイートを受信した
          else
            # その他のツイートを受信した
          end
        when Twitter::DirectMessage
          puts "DirectMessage"
          pp object
        when Twitter::Streaming::DeletedTweet
          puts "DeletedTweet"
          pp object
        when Twitter::Streaming::Event
          puts "Event"
          pp object
        when Twitter::Streaming::FriendList
          puts "FriendList"
          pp object
        when Twitter::Streaming::StallWarning
          puts "StallWarning"
          pp object
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
