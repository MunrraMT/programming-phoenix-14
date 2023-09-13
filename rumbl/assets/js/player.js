const Player = {
  player: null,

  init(domId, playerId, onReady) {
    window.onYouTubeIframeAPIReady = () => {
      this.onIframeReady(domId, playerId, onReady);
    };

    const youtubeScriptTag = document.createElement('script');
    youtubeScriptTag.src = 'https://www.youtube.com/iframe_api';
    document.head.appendChild(youtubeScriptTag);
  },

  onIframeReady(domId, playerId, onReady) {
    this.player = new YT.Player(domId, {
      height: '360',
      width: '420',
      videoId: playerId,
      events: {
        onReady: (event) => onPlayerReady(event),
        onStateChange: (event) => this.onPlayerStateChange(event),
      },
    });
  },

  onPlayerReady(event) {
    event.target.playVideo();
  },

  onPlayerStateChange(event) {},

  getCurrentTime() {
    return Math.floor(this.player.getCurrentTime() * 1000);
  },

  seekTo(milsec) {
    return this.player.seekTo(milsec / 1000);
  },
};

export default Player;
