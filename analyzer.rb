require 'net/http'
require 'rexml/document'
require 'yaml'

module Hibarichan
  class Analyzer
    def initialize(config)
      @appid = config['application_id']
      @secret = config['secret']
      @buffer = [] # 
      @returns = []
      @timestamp = Time.now
    end

    AnalyzerURI = URI.parse('http://jlp.yahooapis.jp/MAService/V1/parse')
    AnalyzerLimit = 10000 # 形態素解析器に渡す文字列の最大バイト数．
    AnalyzeInterval = 600  # 形態素解析を行う時間間隔

    Delimiter = '　'
    EscapeChar = ' '

    def encode(buffer)
      # 渡された文字列の配列について，
      # 全角スペースを区切り文字とした一つの文字列にする
      buffer.collect{|e| e.gsub(Delimiter, EscapeChar)}.join(Delimiter)
    end

    def decode(analyzed)
      # 解析後の情報の配列について，
      # 全角スペースを含む情報を区切り文字として分割した配列を返す
      result = []
      temp = []
      analyzed.each do |wordi|
        if wordi[0] == Delimiter
          result << temp
          temp = []
        else
          temp << wordi
        end
      end
      result << temp
      result
    end

    def push(sentence, obj)
      # 渡された文字列について，
      # 形態素解析の待ち行列に追加する．
      # objには解析結果を渡すべきオブジェクトを指定する．
      # なお，objにはpush_analyzedメソッドを定義のこと．

      if encode(@buffer).size > AnalyzerLimit || Time.now > @timestamp + AnalyzeInterval
        # 渡された文字列を追加すると形態素解析器の上限に触れる場合，
        # または前回の解析から十分に時間が経っている場合，
        # 待ち行列の中身を処理する
        execute
      end

      @buffer << sentence
      @returns << obj
    end

    def execute
      unless @buffer.empty?
        # bufferの中身を形態素解析し，
        # その結果を元の文字列と対応付けられるようデコードし，
        # 解析結果を渡すべきオブジェクトへ結果を返す．
        analyzed = analyze(encode(@buffer))
        decoded = decode(analyzed)

        @returns.size.times do |i|
          @returns[i].push_analyzed(decoded[i])
        end

        # タイムスタンプの更新
        @timestamp = Time.now

        # バッファの初期化
        @buffer = []
        @returns = []
      end
    end

    def analyze(sentence)
      # 渡された文字列を形態素解析して配列にして返す
      # もうちょっとキレイな書き方したい
      result = []
      xml = REXML::Document.new(request(sentence).body)
      xml.elements.each('/ResultSet/ma_result/word_list/word') do |word|
        result << [word[0][0], word[1][0], word[2][0]]
      end
      result
    end

    def request(sentence)
      # 文字列を形態素解析器に渡し，解析結果のXMLを返す
      Net::HTTP.start(AnalyzerURI.host, AnalyzerURI.port) do |http|
        header = {'User-Agent' => "Yahoo AppID: #{@appid}"}
        body = "sentence=#{sentence}"
        http.post(AnalyzerURI.path, body, header)
      end
    end
  end
end
