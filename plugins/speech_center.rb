module Hibarichan
  class SpeechCenter < Plugin
    # ツイートの生成が出来なかった際に，
    # もう一度それを試みるまでの間隔
    RETRY_INTERVAL = 10
    DEFAULT_FRIENDS_COUNT = 200

    def next_interval
      # Box-Muller法を用い，
      # フォロー数 * repo('freq_coef')を平均，
      # 平均 / 3を標準偏差とする正規乱数を生成
      begin
        m = @rest.user.friends_count * (repo['freq_coef'] || 1)
      rescue Twitter::Error::TooManyRequests => e
        p e
      end

      m ||= DEFAULT_FRIENDS_COUNT

      s = m / 3

      (s * Math.sqrt(-2 * Math.log(rand)) *
           Math.sin(2 * Math::PI * rand) + m).round
    end

    def on_tweet(tweet)
      # 文章以外の情報(ハッシュタグ等)をストリップ
      stripped_text = get_stripped_text(tweet)

      # 文字参照をアンエスケープ
      unescaped_text = unescape_html(stripped_text)

      # 学習
      learn unescaped_text

      on_any_event
    end

    def on_any_event
      # インターバルを減算
      @tweet_interval = (@tweet_interval || 0) - 1

      # インターバルを超えていなければ
      # そのまま終了
      return if @tweet_interval >= 0

      # ツイートする文字列生成
      begin
        sentence = get_sentence
      rescue
        # 文字列生成に失敗していたら
        # 次回のインターバルを早める
        @tweet_interval = RETRY_INTERVAL
      else
        # 文字列生成に成功していればツイート
        update sentence

        # インターバル値の更新
        @tweet_interval = next_interval
      end
    end
  end
end
