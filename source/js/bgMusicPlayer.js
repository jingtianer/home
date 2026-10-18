// jingtian-bg-player.js
$(function () {
  const STORAGE_KEY = 'jingtian-bg-player-state';
  const musicList = [
    { name: "周杰伦-麦芽糖.mp3", src: "/home/audio/background/周杰伦-麦芽糖.mp3" },
    { name: "时光机-周杰伦.mp3", src: "/home/audio/background/时光机-周杰伦.mp3" },
    { name: "稻香-周杰伦.mp3", src: "/home/audio/background/稻香-周杰伦.mp3" },
    { name: "七里香-周杰伦.mp3", src: "/home/audio/background/七里香-周杰伦.mp3" },
    { name: "晴天-周杰伦.mp3", src: "/home/audio/background/晴天-周杰伦.mp3" },
  ];

  function readSavedState() {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      return raw ? JSON.parse(raw) : null;
    } catch (e) {
      return null;
    }
  }

  function savePlayerState(player) {
    if (!player || !player.audio) return;
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify({
        currentIndex: player.currentIndex,
        currentTime: player.audio.currentTime || 0,
        volume: player.audio.volume,
        paused: player.audio.paused,
        savedAt: Date.now()
      }));
    } catch (e) { }
  }

  const savedState = readSavedState();

  // ========== 全局单例 ==========
  if (!window.__jingtianAudioPlayer) {
    const audioDom = document.createElement('audio');
    audioDom.controls = false;
    audioDom.preload = 'auto';
    window.__jingtianAudioPlayer = {
      audio: audioDom,
      currentIndex: 0,
      floatBox: null,
      updatePlayingState: function () {
        if (!this.floatBox) return;
        const isPlaying = !this.audio.paused;
        this.floatBox.toggleClass('is-playing', isPlaying);
        this.floatBox.attr('aria-label', isPlaying ? '暂停背景音乐' : '播放背景音乐');
        const $toggle = this.floatBox.find('.jingtian-bg-player__toggle');
        $toggle.html(`<i class="fa-solid ${isPlaying ? 'fa-pause' : 'fa-play'}"></i>`);
        $toggle.attr('aria-label', isPlaying ? '暂停背景音乐' : '播放背景音乐');
      },
      loadMusic: function (idx) {
        if (idx < 0 || idx >= musicList.length) return;
        this.currentIndex = idx;
        const m = musicList[idx];
        this.audio.src = m.src;
        if (this.floatBox) {
          this.floatBox.find('.jingtian-bg-player__title').text(m.name);
        }
      },
      playPrevious: function () {
        const nextIndex = (this.currentIndex - 1 + musicList.length) % musicList.length;
        this.loadMusic(nextIndex);
        this.audio.play().catch(e => console.log('上一首播放失败', e));
      },
      playNext: function () {
        const nextIndex = (this.currentIndex + 1) % musicList.length;
        this.loadMusic(nextIndex);
        this.audio.play().catch(e => console.log('下一首播放失败', e));
      }
    };
    const player = window.__jingtianAudioPlayer;
    player.audio.volume = savedState && typeof savedState.volume === 'number' ? savedState.volume : 1.0;
    player.audio.addEventListener('play', () => {
      player.updatePlayingState();
      savePlayerState(player);
    });
    player.audio.addEventListener('pause', () => {
      player.updatePlayingState();
      savePlayerState(player);
    });
    player.audio.addEventListener('timeupdate', () => savePlayerState(player));
    player.audio.addEventListener('volumechange', () => savePlayerState(player));

    // 播放结束事件：循环列表，播完回到第一首
    player.audio.addEventListener('ended', () => {
      player.currentIndex = (player.currentIndex + 1) % musicList.length;
      player.loadMusic(player.currentIndex);
      player.audio.play().catch(e => console.log('自动切歌播放失败', e));
    })

    const restoredIndex = savedState && Number.isInteger(savedState.currentIndex)
      ? savedState.currentIndex
      : 0;

    player.loadMusic(restoredIndex);

    if (savedState && typeof savedState.currentTime === 'number' && savedState.currentTime > 0) {
      player.audio.addEventListener('loadedmetadata', function restoreProgress() {
        player.audio.removeEventListener('loadedmetadata', restoreProgress);
        const safeTime = Math.min(savedState.currentTime, player.audio.duration || savedState.currentTime);
        player.audio.currentTime = safeTime;
        savePlayerState(player);
        if (!savedState.paused) {
          player.audio.play().catch(e => console.log(e));
        }
      });
    } else {
      player.audio.play().catch(e => console.log(e));
    }
  }

  let hasPlayed = false;
  const audioUnlockEvents = [
    'click',
    'dblclick',
    'mousedown',
    'mouseup',
    'pointerdown',
    'pointerup',
    'touchstart',
    'touchend',
    'keydown',
    'keyup',
    'wheel'
  ];

  function addMusicAutoPlayEvent() {
    // 绑定交互事件
    audioUnlockEvents.forEach(evt => {
      document.addEventListener(evt, firstUserInteraction);
    });
  }
  if (!savedState || !savedState.paused) {
    firstUserInteraction();
    addMusicAutoPlayEvent();
  }

  // 监听常见用户交互事件，只触发一次
  async function firstUserInteraction(e) {
    if (e && $(e.target).closest('.jingtian-bg-player').length) return;
    if (hasPlayed) return;
    hasPlayed = true;
    // 移除所有监听，避免重复
    audioUnlockEvents.forEach(evt => {
      document.removeEventListener(evt, firstUserInteraction);
    });

    try {
      const player = window.__jingtianAudioPlayer;
      await player.audio.play();
      // console.log('播放成功，触发于用户第一次交互');
    } catch (err) {
      console.error('播放失败', err);
      hasPlayed = false;
      addMusicAutoPlayEvent();
    }
  }

  const player = window.__jingtianAudioPlayer;

  if (player.floatBox && player.floatBox.length && player.floatBox.parent().length) {
    return;
  }

  const $floatBox = $(`
    <div class="jingtian-bg-player" aria-label="播放背景音乐">
      <div class="jingtian-bg-player__film global-blur">
        <div class="jingtian-bg-player__record"></div>
      </div>
      <div class="jingtian-bg-player__controls global-blur">
        <div class="jingtian-bg-player__buttons">
          <button class="jingtian-bg-player__button jingtian-bg-player__prev global-blur" type="button" aria-label="上一首"><i class="fa-solid fa-backward-step"></i></button>
          <button class="jingtian-bg-player__button jingtian-bg-player__toggle global-blur" type="button" aria-label="播放背景音乐"><i class="fa-solid fa-play"></i></button>
          <button class="jingtian-bg-player__button jingtian-bg-player__next global-blur" type="button" aria-label="下一首"><i class="fa-solid fa-forward-step"></i></button>
        </div>
      </div>
      <div class="jingtian-bg-player__volume-control global-blur">
        <input class="jingtian-bg-player__volume" type="range" min="0" max="1" step="0.01" value="1" aria-label="背景音乐音量">
      </div>
      <div class="jingtian-bg-player__title">--</div>
      <div class="jingtian-bg-player__audio-wrap"></div>
    </div>
  `);
  $('body').append($floatBox);
  player.floatBox = $floatBox;

  // audio移入浮窗内部容器
  $floatBox.find('.jingtian-bg-player__audio-wrap').append(player.audio);

  const $title = $floatBox.find('.jingtian-bg-player__title');
  const $volume = $floatBox.find('.jingtian-bg-player__volume');
  const $controls = $floatBox.find('.jingtian-bg-player__controls');
  const $prev = $floatBox.find('.jingtian-bg-player__prev');
  const $next = $floatBox.find('.jingtian-bg-player__next');
  const $toggle = $floatBox.find('.jingtian-bg-player__toggle');

  const curSong = musicList[player.currentIndex];
  $title.text(curSong.name);
  $volume.val(player.audio.volume);
  player.updatePlayingState();
  savePlayerState(player);

  window.addEventListener('pagehide', () => savePlayerState(player));
  window.addEventListener('beforeunload', () => savePlayerState(player));

  async function togglePlay() {
    if (player.audio.paused) {
      try {
        await player.audio.play();
      } catch (err) {
        console.error('播放失败', err);
      }
    } else {
      player.audio.pause();
    }
    player.updatePlayingState();
    savePlayerState(player);
  }

  //拖拽
  let isDrag = false;
  let hasDragged = false;
  let offsetX, offsetY;
  let startX, startY;
  $floatBox.on('mousedown', function (e) {
    if ($(e.target).closest('.jingtian-bg-player__volume-control, .jingtian-bg-player__controls').length) return;
    isDrag = true;
    hasDragged = false;
    startX = e.clientX;
    startY = e.clientY;
    const rect = this.getBoundingClientRect();
    offsetX = e.clientX - rect.left;
    offsetY = e.clientY - rect.top;
    $(this).css('cursor', 'grabbing');
  })
  $(document).on('mousemove', function (e) {
    if (!isDrag) return;
    if (Math.abs(e.clientX - startX) > 3 || Math.abs(e.clientY - startY) > 3) {
      hasDragged = true;
    }
    let x = e.clientX - offsetX;
    let y = e.clientY - offsetY;
    const w = $floatBox.outerWidth();
    const h = $floatBox.outerHeight();
    x = Math.max(0, Math.min(window.innerWidth - w, x));
    y = Math.max(0, Math.min(window.innerHeight - h, y));
    $floatBox.css({ left: x + 'px', bottom: 'auto', top: y + 'px' })
  })
  $(document).on('mouseup', () => {
    isDrag = false;
    $floatBox.css('cursor', 'move');
  })
  $floatBox.on('click', function (e) {
    e.stopPropagation();
    if ($(e.target).closest('.jingtian-bg-player__volume-control, .jingtian-bg-player__controls').length) return;
    if (hasDragged) return;
    togglePlay();
  })
  $controls.on('mousedown mouseup click input change keydown', function (e) {
    e.stopPropagation();
  })
  $prev.on('click', function (e) {
    e.stopPropagation();
    player.playPrevious();
  })
  $next.on('click', function (e) {
    e.stopPropagation();
    player.playNext();
  })
  $toggle.on('click', function (e) {
    e.stopPropagation();
    togglePlay();
  })
  $volume.on('mousedown mouseup click input change keydown', function (e) {
    e.stopPropagation();
    player.audio.volume = Number(this.value);
    savePlayerState(player);
  })
})
