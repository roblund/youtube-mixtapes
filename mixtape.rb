require 'yt'
require 'pp'
require 'date'

class Mixtape
  @@channels = [
    'UCJ6td3C9QlPO9O_J5dF4ZzA', # monstercat
    'UCNyo1qwT4ZKuoWsyrrdoc6g', # med school
    'UCpEYMEafq3FsKCQXNliFY9A', # arctic empire
    'UCxaLJvYDW8XMgrNbdnZ-uMQ', # camo and krooked
    'UCD7UAd18FFkcJ22wxNNwq7A', # dirty bird
    'UCkUTBwZKwA9ojYqzj6VRlMQ', # one chilled panda
    'UCyCK2Qw6YnmZzpsIwZ2CT6g', # rusted media
    'UChVfER-3s533FTh8Uae0Rhg', # seven lions
    'UC2EMLFSTChy7wpL72D-23Ug', # solar heavy
    'UCROK2sVv9Jhxcpha8v4A8KA', # spearhead
    'UCLTZddgA_La9H4Ngg99t_QQ', # suicide sheeep
    'UC0n9yiP-AD2DpuuYCDwlNxQ', # tasty
    'UCH3V-b6weBfTrDuyJgFioOw', # the dub rebellion
    'UCr8oc-LOaApCXWLjL7vdsgw', # UKF DnB
    'UCfLFTP1uTuIizynWsZq2nkQ', # UKF Dubstep
  ]

  def initialize
    Yt.configure do |config|
      # config.log_level = :debug
      config.client_id = ENV['youtube_client_id']
      config.client_secret = ENV['youtube_client_secret']
    end
  end

  def get_videos
    Yt.configuration.api_key = ENV['youtube_api_key']
    lastWeek = []

    @@channels.each do |channelId|
      channel = Yt::Channel.new id: channelId
      vidCollection = channel.videos.where(publishedAfter: 1.week.ago.to_datetime.rfc3339)
      lastWeek << vidCollection.map{|v| v.id}
    end

    lastWeek = lastWeek.flatten

    if Yt.configuration.log_level == :debug
      pp lastWeek
    end

    # blank out api_key because the Yt api doesn't like to do oauth based requests with it enabled
    Yt.configuration.api_key = ""

    return lastWeek
  end

  def create_playlist(videos)
    account = Yt::Account.new(refresh_token: ENV['youtube_refresh_token'])

    mixtapePlaylist = account.create_playlist(title: "Mixtape " + DateTime.now.strftime("%D"))
    mixtapePlaylist.add_videos(videos.shuffle, auth: account)

    return mixtapePlaylist.id
  end
end

tape = Mixtape.new
videos = tape.get_videos
playlistId = tape.create_playlist(videos)

puts "https://www.youtube.com/playlist?list=" + playlistId
