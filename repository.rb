require 'pathname'

module Hibarichan
  class Repository

    SaveInterval = 600

    def initialize(path)
      # ファイル読み込み
      @path = path
      if File.exist?(@path)
        Pathname.new(@path).open('rb') do |f|
          @data = Marshal.load(f)
        end
      else
        @data = {}
      end

      # 自動保存のためのタイムスタンプ
      @timestamp = Time.now
    end

    def [](key)
      # キーによるハッシュ取り出し
      @data[key] ||= {}
      @data[key]
    end

    def auto_save
      # 名前は紛らわしいが，必ずセーブするわけではない．
      # タイムスタンプからSaveInterval秒より過ぎていたら，
      # 自動セーブするメソッド

      if Time.now > @timestamp + SaveInterval
        # セーブする
        save
        # タイムスタンプの更新
        @timestamp = Time.now
      end
    end

    def save
      # データをファイルへ保存
      Pathname.new(@path).open('wb') do |f|
        Marshal.dump(@data, f)
      end
    end
  end
end
