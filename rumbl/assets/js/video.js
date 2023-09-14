import Player from './player';

const Video = {
  init(socket, element) {
    if (!element) return;

    const playerId = element.getAttribute('data-player-id');
    const videoId = element.getAttribute('data-id');

    socket.connect();

    Player.init(element.id, playerId, () => {
      this.onReady(videoId, socket);
    });
  },

  onReady(videoId, socket) {
    const msgContainer = document.querySelector('#msg-container');
    const msgInput = document.querySelector('#msg-input');
    const postButton = document.querySelector('#msg-submit');
    const vidChannel = socket.channel('videos:' + videoId);

    vidChannel.on('ping', ({ count }) => {
      console.log('PING', count);
    });

    vidChannel
      .join()
      .receive('ok', (resp) => {
        console.log('Joined the video channel', resp);
      })
      .receive('error', (reason) => {
        console.log('Join failed', reason);
      });
  },
};

export default Video;
