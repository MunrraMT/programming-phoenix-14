import Player from './player';

const video = {
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
    const postButton = document.querySelector('#msg-sumbit');
    const vidChannel = socket.channel('videos:' + videoId);
  },
};

export default video;
