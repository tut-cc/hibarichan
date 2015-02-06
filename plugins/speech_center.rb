module Hibarichan
  class SpeechCenter < Plugin

    # ツイートの生成が出来なかった際に，
    # もう一度それを試みるまでの間隔
    RetryInterval = 10
    DefaultFriendsCount = 200

    def get_next_interval
      # Box-Muller法を用い，
      # フォロー数 * 0.6を平均，
      # 平均 / 3を標準偏差とする正規乱数を生成

      # 結果が負の数になることも多いが，
      # 連投ツイートが行われることは自然であるため，
      # そのままにしている．

      begin
        m = @rest.user.friends_count * 0.6
      rescue Twitter::Error::TooManyRequests => e
        p e
      end

      m ||= DefaultFriendsCount

      s = m / 3

      (s * Math::sqrt(-2 * Math::log(rand)) *
           Math::sin(2 * Math::PI * rand) + m).round
    end

    def on_tweet(tweet)
      # 受け取ったツイートについて学習を行う
      learn get_stripped_text(tweet)

      on_any_event
    end

    def on_any_event
      # インターバルを減算
      @tweet_interval = (@tweet_interval || 0) - 1

      # インターバルを終えていたら
      if @tweet_interval < 0
        # ツイートする文字列生成
        begin
          sentence = get_sentence
        rescue
          # 文字列生成に失敗していたら
          # 次回のインターバルを早める
          @tweet_interval = RetryInterval
        else
          # 文字列生成に成功していればツイート
          update sentence

          # インターバル値の更新
          @tweet_interval = get_next_interval
        end
      end
    end
  end
end
