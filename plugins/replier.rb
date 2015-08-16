module Hibarichan
  class Replier < Plugin
    def on_reply(tweet)
      user_name = tweet.attrs[:user][:screen_name]
      begin
        sentence = get_sentence(140 - (user_name.size + 2))
      rescue => e
        p e
      else
        update("@#{user_name} #{sentence}", in_reply_to_status: tweet)
      end
    end
  end
end
