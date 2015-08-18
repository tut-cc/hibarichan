require 'twitter'
require './repository'
require './markov'
require './plugin'

module Hibarichan
  class Hibarichan
    def initialize(setting_file_path)
      # リポジトリの読み込み
      @repository = Repository.new(setting_file_path)

      # Streaming Client作成
      @stream = Twitter::Streaming::Client.new(@repository['twitter_auth'])

      # REST Client作成
      @rest = Twitter::REST::Client.new(@repository['twitter_auth'])

      # 文章生成器作成
      @markov = Markov.new(@repository['yahoo_auth'], @repository['markov'])

      # プラグインの読み込み
      @pmanager = PluginManager.new(@rest, @markov, @repository)

      # 自分自身のIDの読み出し
      @my_id = @rest.user.id
    end

    def run
      # stream のブロックの処理
      run_block = lambda do |object|
        # オブジェクトの種類ごとに動作する
        operate(object)

        # リポジトリの自動セーブ
        @repository.auto_save
      end

      if $sample
        # sample stream (デバッグ用)
        @stream.sample(&run_block)
      else
        # user stream
        @stream.user(&run_block)
      end
    end

    def operate(object)
      case object
      when Twitter::Tweet
        if object.retweeted_tweet?
          # 誰かのリツイートを受信した
          @pmanager.on_retweet(object)
        elsif object.in_reply_to_user_id == @my_id
          # 自分宛のツイートを受信した
          @pmanager.on_reply(object)
        elsif object.attrs[:user][:id] != @my_id
          # (自分のツイートを除く)その他のツイートを受信した
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
    end
  end
end
