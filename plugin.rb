require 'pluggable_lite'

module Hibarichan
  class Plugin
    extend PluggableLite::Plugin

    public
    def initialize(rest, markov)
      @rest = rest
      @markov = markov
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
      # @rest.update(tweet)
      puts "「#{tweet}」"
    end

    def learn(str)
      @markov.learn(str)
    end

    def get_sentence
      begin
        # 文字列生成
        @markov.get_sentence
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
end
