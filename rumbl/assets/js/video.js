import Player from './player';
import { Presence } from 'phoenix';

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
    const userList = document.querySelector('#user-list');

    let lastSeenId = 0;

    const vidChannel = socket.channel('videos:' + videoId, () => {
      return { last_seen_id: lastSeenId };
    });

    const presence = new Presence(vidChannel);

    presence.onSync(() => {
      userList.innerHTML = presence
        .list((id, { user: user, metas: [first, ...rest] }) => {
          const count = rest.length + 1;
          return `<li>${user.username}: (${count})</li>`;
        })
        .join('');
    });

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
      lastSeenId = resp.id;
      this.renderAnnotation(msgContainer, resp);
    });

    vidChannel
      .join()
      .receive('ok', (resp) => {
        const ids = resp.annotations.map((ann) => ann.id);
        if (ids.length > 0) lastSeenId = Math.max(...ids);
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
