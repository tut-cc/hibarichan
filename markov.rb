require './analyzer'
require 'digest/md5'

# 標準のStringはキー値がRubyの起動毎に変化する．
# 保存した際にそれはちょっとつらいので，
# hashメソッドを文字列のMD5ハッシュとするようにオーバライド．
class String
  def hash
    # Fixnumの値の範囲
    # -fixnum_range / 2 〜 fixnum_range / 2 - 1
    fixnum_range = (2**(0.size * 8 - 1))

    # 文字列からMD5ハッシュをとる
    md5value = Digest::MD5.new.update(self).to_s.to_i(16)

    # MD5ハッシュの値をFixnumの範囲内に収める
    md5value % fixnum_range - (fixnum_range / 2)
  end

  def eql?(other)
    hash == other.hash
  end
end

module Hibarichan
  class Markov
    def initialize(yahoo_auth, knowledge, limit = 100)
      # 構文解析器作成
      @analyzer = Analyzer.new(yahoo_auth)

      # コンストラクタ引数をインスタンス変数に
      @knowledge = knowledge # 知識データ
      @limit = limit # 試行回数の制限値
    end

    SRT = 'START FLG'
    STP = 'STOP FLG'

    def learn(sentence)
      @analyzer.push(sentence, self)
    end

    def push_analyzed(words)
      [[SRT], [SRT], *words, [STP]].each_cons(3) do |w, x, y|
        @knowledge[[w[0], x[0]]] ||= Set.new
        @knowledge[[w[0], x[0]]] << y[0]
      end
    end

    def get_sentence(length = 140)
      if @knowledge.empty?
        # 知識がない場合には，
        # とりあえず形態素解析器のバッファを処理してみる．
        @analyzer.execute

        # それでも知識がなければ，例外を投げる
        fail 'No knowledge' if @knowledge.empty?
      end

      @limit.times do
        str = generate
        return str if str.size <= length
      end
      fail 'Failed to generate sentence'
    end

    def generate
      # 文章の生成
      sentence = [SRT, SRT]

      loop do
        sentence << @knowledge[sentence[-2, 2]].to_a.sample
        break if sentence[-1] == STP
      end
      sentence[2..-2].join
    end
  end
end
