require './analyzer'

module Hibarichan
  class Markov
    def initialize(config, path, limit = 100)
      # 構文解析器作成
      @analyzer = Analyzer.new(config)

      # 文字列生成の試行回数制限
      @limit = limit

      # ファイル読み込み
      @path = path
      if File.exist?(@path)
        Pathname.new(@path).open('rb') do |f|
          @knowledge = Marshal.load(f)
        end
      else
        @knowledge = {}
      end
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
        raise 'No knowledge' if @knowledge.empty?
      end

      @limit.times do
        str = generate
        return str if str.size <= length
      end
      raise 'Failed to generate sentence'
    end

    def generate
      # 文章の生成
      sentence = [SRT, SRT]

      # do-while文として以下のように書くのはよくないらしい(？)
      # どうやって書くべきなんだろ？
      begin
        sentence << @knowledge[sentence[-2, 2]].to_a.sample
      end until sentence[-1] == STP
      sentence[2..-2].join
    end

    def save
      # 形態素解析器のバッファを処理
      @analyzer.execute

      # 保存
      Pathname.new(@path).open('wb') do |f|
        Marshal.dump(@knowledge, f)
      end
    end
  end
end
