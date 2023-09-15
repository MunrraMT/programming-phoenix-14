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

  esc(str) {
    const div = document.createElement('div');
    div.appendChild(document.createTextNode(str));
    return div.innerHTML;
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
        this.scheduleMessages(msgContainer, resp.annotations);
      })
      .receive('error', (reason) => {
        console.log('Join failed', reason);
      });
  },

  renderAnnotation(msgContainer, { user, body, at }) {
    const template = document.createElement('div');

    template.innerHTML = `
    <a href="#" data-seek="${this.esc(at)}">
      [${this.formatTime(at)}]
      <strong>${this.esc(user.username)}: </strong>
      <span>${this.esc(body)}</span>
    </a>
    `;

    template.addEventListener('click', () => {
      Player.seekTo(this.esc(at));
    });

    msgContainer.appendChild(template);
    msgContainer.scrollTop = msgContainer.scrollHeight;
  },

  scheduleMessages(msgContainer, annotations) {
    clearTimeout(this.scheduleTimer);

    this.scheduleTimer = setTimeout(() => {
      const ctime = Player.getCurrentTime();
      const remaining = this.renderAtTime(annotations, ctime, msgContainer);

      this.scheduleMessages(msgContainer, remaining);
    }, 1000);
  },

  renderAtTime(annotations, seconds, msgContainer) {
    return annotations.filter((ann) => {
      if (ann.at > seconds) return true;
      this.renderAnnotation(msgContainer, ann);
      return false;
    });
  },

  formatTime(at) {
    const date = new Date(null);
    date.setSeconds(at / 1000);
    return date.toISOString().slice(14, -5);
  },
};

export default Video;
