require 'pluggable_lite'
require './plugin'

module Hibarichan
  class PluginManager
    extend PluggableLite::PluginManager

    # Pluginクラスをベースクラスとして登録
    register Plugin

    def initialize(rest, markov)
      # ディレクトリ登録
      PluginManager::load('plugins')

      # プラグインのインスタンス作成
      @plugins = []
      PluginManager::plugins.each do |plugin_class|
        @plugins << plugin_class.new(rest, markov)
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
