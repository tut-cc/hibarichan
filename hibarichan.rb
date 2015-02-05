#!/bin/ruby

require 'twitter'
require 'yaml'
require './repository'
require './markov'
require './plugin'

module Hibarichan
  class Hibarichan
    def initialize(setting_file)
      # YAMLを読む
      settings = YAML.load_file(setting_file)

      # Streaming Client作成
      @stream = Twitter::Streaming::Client.new(settings['twitter'])

      # REST Client作成
      @rest = Twitter::REST::Client.new(settings['twitter'])

      # リポジトリの読み込み
      @repository = Repository.new(settings['repository'])

      # 文章生成器作成
      @markov = Markov.new(settings['yahoo'], @repository)

      # プラグインの読み込み
      @pmanager = PluginManager.new(@rest, @markov)
    end

    def run
      # 自分のユーザID
      user_id = @rest.user.id

      @stream.user do |object|
        case object
        when Twitter::Tweet
          if object.retweeted_tweet?
            # 誰かのリツイートを受信した
            @pmanager.on_retweet(object)
          elsif object.in_reply_to_user_id == user_id
            # 自分宛のツイートを受信した
            @pmanager.on_reply(object)
          else
            # その他のツイートを受信した
            @pmanager.on_tweet(object)
          end
        when Twitter::DirectMessage
          # ダイレクトメッセージを受信した
          @pmanager.on_dmessage(object)
        when Twitter::Streaming::DeletedTweet
          # ツイートが削除された
          @pmanager.on_delete(object)
        when Twitter::Streaming::Event
          # イベントが発生した
          @pmanager.on_event(object)
        when Twitter::Streaming::FriendList
          # フレンドリストを受信した
          @pmanager.on_friendlist(object)
        when Twitter::Streaming::StallWarning
          # よくわからない．なんかの警告でしょ(適当)
          @pmanager.on_stallwarning(object)
        end

        # リポジトリの自動セーブ
        @repository.auto_save
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
