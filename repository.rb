require 'yaml'
require 'pathname'

module Hibarichan
  class Repository

    SaveInterval = 600

    def initialize(setting_file_path)
      # YAMLを読む
      settings = YAML::load_file(setting_file_path)

      # リポジトリファイル読み込み
      @path = settings['repository']
      if File::exist?(@path)
        Pathname.new(@path).open('rb') do |f|
          @data = Marshal::load(f)
        end
      else
        @data = {}
      end

      # settingsの値にリポジトリのデータを更新
      @data.merge!(settings)

      # 自動保存のためのタイムスタンプ
      @timestamp = Time::now
    end

    def [](key)
      # nilならとりあえずハッシュで初期化しておく．
      # 使う側がこのハッシュを使うかどうかはおまかせで．
      @data[key] ||= {}
      @data[key]
    end

    def auto_save
      # 名前は紛らわしいが，必ずセーブするわけではない．
      # タイムスタンプからSaveInterval秒より過ぎていたら，
      # 自動セーブするメソッド

      if Time::now > @timestamp + SaveInterval
        # セーブする
        save
        # タイムスタンプの更新
        @timestamp = Time::now
      end
    end

    def save
      # データをファイルへ保存
      Pathname.new(@path).open('wb') do |f|
        Marshal::dump(@data, f)
      end
    end
  end
end
