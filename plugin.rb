require 'pluggable_lite'

module Hibarichan
  class Plugin
    extend PluggableLite::Plugin

    public
    def initialize(rest, markov, repository)
      @rest = rest
      @markov = markov
      @repository = repository
    end

    def on_retweet(tweet)
      on_any_event
    end

    def on_reply(tweet)
      on_any_event
    end

    def on_tweet(tweet)
      on_any_event
    end

    def on_dmessage(dmessage)
      on_any_event
    end

    def on_delete(tweet)
      on_any_event
    end

    def on_event(event)
      on_any_event
    end

    def on_friendlist(friendlist)
      on_any_event
    end

    def on_stallwarning(stallwarning)
      on_any_event
    end

    def on_any_event
    end

    private
    def update(tweet)
      @rest.update(tweet)
    end

    def learn(str)
      @markov.learn(str)
    end

    def get_sentence(length = 140)
      begin
        # 文字列生成
        @markov.get_sentence(length)
      rescue => e
        # 例外が発生したらそのまま投げる
        raise e
      end
    end

    def tweet_strip(tweet)
      # アットを削除
      tweet.gsub(/@[0-9a-zA-Z_]{1,15}/, ' ').

      # ハッシュタグを削除
      gsub(/[#＃][0-9a-zA-Z０-９ａ-ｚＡ-Ｚ〃々〻ぁ-ヿ一-鿆]/, '').

      # URLを削除
      gsub(/https?:\/\/[-a-zA-Z0-9._~:\/?#@!$&'()*+,;=%]+/, ' ')
    end
  end

  class PluginManager
    extend PluggableLite::PluginManager

    # Pluginクラスをベースクラスとして登録
    register Plugin

    def initialize(rest, markov, repository)
      # ディレクトリ登録
      PluginManager::load('plugins')

      # プラグインのインスタンス作成
      @plugins = []
      PluginManager::plugins.each do |plugin_class|
        @plugins << plugin_class.new(rest, markov, repository)
      end
    end

    def on_tweet(tweet)
      @plugins.each do |plugin|
        plugin.on_tweet(tweet)
      end
    end

    def on_reply(tweet)
      @plugins.each do |plugin|
        plugin.on_reply(tweet)
      end
    end

    def on_retweet(tweet)
      @plugins.each do |plugin|
        plugin.on_retweet(tweet)
      end
    end

    def on_dmessage(dmessage)
      @plugins.each do |plugin|
        plugin.on_dmessage(dmessage)
      end
    end

    def on_delete(deletedtweet)
      @plugins.each do |plugin|
        plugin.on_delete(deletedtweet)
      end
    end

    def on_event(event)
      @plugins.each do |plugin|
        plugin.on_event(event)
      end
    end

    def on_friendlist(friendlist)
      @plugins.each do |plugin|
        plugin.on_friendlist(friendlist)
      end
    end

    def on_stallwarning(stallwarning)
      @plugins.each do |plugin|
        plugin.on_stallwarning(stallwarning)
      end
    end
  end
end
