# This is a simple example Widget, written in CoffeeScript, to get you started
# with Übersicht. For the full documentation please visit:
#
# https://github.com/felixhageloh/uebersicht
#
# You can modify this widget as you see fit, or simply delete this file to
# remove it.

# the CSS style for this widget, written using Stylus
# (http://learnboost.github.io/stylus/)

# the refresh frequency in milliseconds
refreshFrequency: 1000

style: """

  player = 1
  bottom = 97.6%
  right = 56.3%

  bottom: bottom
  right: right
  background-color: rgba(0, 0, 0, 0.8)
  width: 280px;
  height: 15px;
  display: flex;
  padding: 5px;
  border-radius: 5px;
  align-items: center;
  font-family: "PT Mono"
  justify-content: space-around;
  font-size: 13px;

  .track-name
    color: rgb(47,213,102)

  .artist-name
    color: rgb(255,255,255)

  .player
    text-align: center
	& i
      font-size: 12px
    & i.hidden
      display: none

@font-face {
    font-family: PT Mono;
    src: url("./fonts/PTMono-Regular.ttf") format("opentype");
}

"""

# this is the shell command that gets executed every time this widget refreshes
command: "source Spotify-AdSilencer.widget/spotify-info.sh"

# render gets called after the shell command has executed. The command's output
# is passed in as a string. Whatever it returns will get rendered as HTML.
render: (output) -> """
  <div class="track-name" name="track"></div>
  <div class="artist-name" name="artist"></div>
  <div class="player" name="player">
    <i style="color: white;" class="fa fa-backward" name="song-backward" aria-hidden="true"></i>
    <i style="color: white; "class="fa fa-play" name="song-play" aria-hidden="true"></i>
    <i style="color: white;" class="fa fa-pause hidden" name="song-pause" aria-hidden="true"></i>
    <i style="color: white;" class="fa fa-forward" name="song-forward" aria-hidden="true"></i>
  </div>
"""

# Update the rendered output.
update: (output, domEl) ->

  adDetected = (self) ->
    $('[name="track"]').html("Ad detected")
    $('[name="artist"]').html("Ad detected")
    $('[name="album-img"]').attr('src','Spotify-AdSilencer.widget/images/ad.png')
    self.run "osascript -e 'tell application \"Spotify\" to set sound volume to 0'"
    self.run "osascript -e 'display notification \"Spotify Ad detected\"'"
    localStorage.setItem "spotifyAd", 1
    #localStorage.setItem "spotifyVolume", 0

  setTrackName = ( trackName ) ->
    trackName = cutStringToFill(trackName)

    $('[name="track"]').html(trackName)

  setArtistName = ( artistName ) ->
    artistName = cutStringToFill(artistName)

    $('[name="artist"]').html(artistName)

  setAlbumImage = ( albumUrl ) ->
    $('[name="album-img"]').attr('src',albumUrl)
    $('[name="album-img"]').attr('width','100px')
    $('[name="album-img"]').attr('height','100px')

  getSpotifyVolume = (self, callback) ->

    getSpotifyVolumeScript = """
      osascript <<<'tell application "Spotify"
        set soundVolume to sound volume
        return  soundVolume
      end tell'"""

    self.run getSpotifyVolumeScript, (error, data) ->
      if data?
        callback(data)

  setSpotifyVolume = (self,volume) ->
    volume = parseInt(volume, 10) + 1
    setSpotifyVolumeCommand = "osascript -e 'tell application \"Spotify\" to set sound volume to " + volume + "'"
    self.run setSpotifyVolumeCommand

  fromAd = (self) ->
    fromSpotifyAd = localStorage.getItem "spotifyAd"
    if fromSpotifyAd? and fromSpotifyAd is "1"
      spotifyVolume = localStorage.getItem "spotifyVolume"
      setSpotifyVolume(self,spotifyVolume)
      localStorage.setItem "spotifyAd", 0
    else
      getSpotifyVolume( self, (spotifyVolume) ->
        localStorage.setItem "spotifyVolume", spotifyVolume
      )

  cutStringToFill = (string) ->
    maxLength = 27
    stringLength = string.length
    if stringLength > maxLength
      string = string.substring(0,maxLength-2) + " ..."

    return string

  playPausePlayer = (playerState) ->
    if playerState.trim() in ['paused', 'stopped']
      $('[name="song-pause"]').addClass('hidden')
      $('[name="song-play"]').removeClass('hidden')
    else if playerState.trim() in ['playing']
      $('[name="song-play"]').addClass('hidden')
      $('[name="song-pause"]').removeClass('hidden')

  trackInfoArray = output.split "|"
  if trackInfoArray
    trackName = trackInfoArray[0]
    playerState = trackInfoArray[3]
    playPausePlayer(playerState)
    if trackName
      setTrackName(trackName)
      artistName = trackInfoArray[1]
      if artistName
        setArtistName(artistName)
        fromAd(this)
        albumUrl = trackInfoArray[2]
        if albumUrl
          setAlbumImage(albumUrl)
      else
        adDetected(this)

    else
      adDetected(this)

afterRender: (domEl)->

  playPauseSong = (self) ->
    self.run "osascript -e 'tell application \"Spotify\" to playpause'"

  forwardSong = (self) ->
    self.run "osascript -e 'tell application \"Spotify\" to next track'"

  backwardSong = (self)->
    self.run "osascript -e 'tell application \"Spotify\" to previous track'"

  self = this

  $(domEl).find('[name="song-play"]').on 'click', =>
    playPauseSong(self)
    $('[name="song-play"]').addClass('hidden')
    $('[name="song-pause"]').removeClass('hidden')

  $(domEl).find('[name="song-pause"]').on 'click', =>
    playPauseSong(self)
    $('[name="song-pause"]').addClass('hidden')
    $('[name="song-play"]').removeClass('hidden')

  $(domEl).find('[name="song-forward"]').on 'click', =>
    forwardSong(self)
    $('[name="song-play"]').addClass('hidden')
    $('[name="song-pause"]').removeClass('hidden')

  $(domEl).find('[name="song-backward"]').on 'click', =>
    backwardSong(self)
    $('[name="song-play"]').addClass('hidden')
    $('[name="song-pause"]').removeClass('hidden')
