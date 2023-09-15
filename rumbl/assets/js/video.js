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

    postButton.addEventListener('click', (e) => {
      const payload = {
        body: msgInput.value,
        at: Player.getCurrentTime(),
      };

      vidChannel
        .push('new_annotation', payload)
        .receive('error', (e) => console.log(e));

      msgInput.value = '';
    });

    vidChannel.on('new_annotation', (resp) => {
      this.renderAnnotation(msgContainer, resp);
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

  esc(str) {
    const div = document.createElement('div');
    div.appendChild(document.createTextNode(str));
    return div.innerHTML;
  },

  renderAnnotation(msgContainer, { user, body, at }) {
    const template = document.createElement('div');

    template.innerHTML = `
    <a href="#" data-seek="${this.esc(at)}">
      <strong>${this.esc(user.username)}: </strong>
      <span>${this.esc(body)}</span>
    </a>
    `;

    msgContainer.appendChild(template);
    msgContainer.scrollTop = msgContainer.scrollHeight;
  },
};

export default Video;
