require 'pluggable_lite'
require 'cgi'

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
      begin
        #@rest.update(tweet)
        puts tweet
      rescue => e
        p e
      end
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

    def unescape_html(text)
      CGI::unescapeHTML(text)
    end
    
    def get_stripped_text(tweet)
      text = tweet.text.dup

      # メンションを削除
      if tweet.user_mentions?
        tweet.user_mentions.each do |mnt|
          text.gsub!('@' + mnt.attrs[:screen_name], '')
        end
      end

      # ハッシュタグを削除
      if tweet.hashtags?
        tweet.hashtags.each do |htag|
          text.gsub!('#' + htag.attrs[:text], '')
        end
      end

      # URLを削除
      if tweet.uris?
        tweet.uris.each do |uri|
          text.gsub!(uri.attrs[:url], '')
        end
      end

      # メディアを削除
      if tweet.media?
        tweet.media.each do |med|
          text.gsub!(med.attrs[:url], '')
        end
      end

      # シンボルを削除
      if tweet.symbols?
        tweet.symbols.each do |sym|
          text.gsub!('$' + sym.attrs[:text], '')
        end
      end

      # 連続する空白を集約
      text.gsub!(/ +/, ' ')

      # 先頭・末尾の空白の除去
      text.strip!

      text
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
