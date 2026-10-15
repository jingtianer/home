// jingtian-bg-player.js
$(function(){
  const musicList = [
    { name: "稻香-周杰伦.mp3", src: "/home/audio/background/稻香-周杰伦.mp3" },
    { name: "七里香-周杰伦.mp3", src: "/home/audio/background/七里香-周杰伦.mp3" },
    { name: "晴天-周杰伦.mp3", src: "/home/audio/background/晴天-周杰伦.mp3" },
    { name: "时光机-周杰伦.mp3", src: "/home/audio/background/时光机-周杰伦.mp3" },
  ];

  // ========== 全局单例 ==========
  if(!window.__jingtianAudioPlayer){
    const audioDom = document.createElement('audio');
    audioDom.controls = true; // 开启原生控件
    window.__jingtianAudioPlayer = {
      audio: audioDom,
      currentIndex: 0,
      floatBox: null,
      loadMusic: function(idx){
        if(idx <0 || idx >= musicList.length) return;
        this.currentIndex = idx;
        const m = musicList[idx];
        this.audio.src = m.src;
        if(this.floatBox){
          this.floatBox.find('.jingtian-bg-player__title').text(m.name);
        }
      }
    };
    const player = window.__jingtianAudioPlayer;
    player.audio.volume = 1.0;

    // 播放结束事件：循环列表，播完回到第一首
    player.audio.addEventListener('ended', ()=>{
      player.currentIndex = (player.currentIndex +1) % musicList.length;
      player.loadMusic(player.currentIndex);
      player.audio.play().catch(e=>console.log('自动切歌播放失败',e));
    })

    // 加载第一首
    player.loadMusic(0);
    player.audio.play().catch(e=>console.log(e));
  }

let hasPlayed = false;

// 监听常见用户交互事件，只触发一次
async function firstUserInteraction() {
  if (hasPlayed) return;
  hasPlayed = true;
  // 移除所有监听，避免重复
  ['click', 'touchstart', 'keydown'].forEach(evt => {
    document.removeEventListener(evt, firstUserInteraction);
  });

  try {
    const player = window.__jingtianAudioPlayer;
    await player.audio.play();
    console.log('播放成功，触发于用户第一次交互');
  } catch (err) {
    console.error('播放失败', err);
  }
}

// 绑定交互事件
['click', 'touchstart', 'keydown'].forEach(evt => {
  document.addEventListener(evt, firstUserInteraction);
});

  const player = window.__jingtianAudioPlayer;

  if(player.floatBox && player.floatBox.length && player.floatBox.parent().length){
    return;
  }

  const $floatBox = $(`
    <div class="jingtian-bg-player">
      <div class="jingtian-bg-player__header">
        <div class="jingtian-bg-player__title">--</div>
        <button class="jingtian-bg-player__close-btn">×</button>
      </div>
      <div class="jingtian-bg-player__audio-wrap"></div>
    </div>
  `);
  $('body').append($floatBox);
  player.floatBox = $floatBox;

  // audio移入浮窗内部容器
  $floatBox.find('.jingtian-bg-player__audio-wrap').append(player.audio);

  const $title = $floatBox.find('.jingtian-bg-player__title');
  const $closeBtn = $floatBox.find('.jingtian-bg-player__close-btn');

  const curSong = musicList[player.currentIndex];
  $title.text(curSong.name);

  //关闭按钮：移回audio到body，防止被删除
  $closeBtn.on('click',function(){
    $(player.audio).appendTo('body');
    $floatBox.remove();
    player.floatBox = null;
    player.audio.pause();
  })

  //拖拽
  let isDrag = false;
  let offsetX, offsetY;
  $floatBox.on('mousedown',function(e){
    const target = e.target;
    if(target.tagName === 'BUTTON') return;
    isDrag = true;
    const rect = this.getBoundingClientRect();
    offsetX = e.clientX - rect.left;
    offsetY = e.clientY - rect.top;
    $(this).css('cursor','grabbing');
  })
  $(document).on('mousemove',function(e){
    if(!isDrag) return;
    let x = e.clientX - offsetX;
    let y = e.clientY - offsetY;
    const w = $floatBox.outerWidth();
    const h = $floatBox.outerHeight();
    x = Math.max(0, Math.min(window.innerWidth - w, x));
    y = Math.max(0, Math.min(window.innerHeight - h, y));
    $floatBox.css({left:x+'px',bottom:'auto',top:y+'px'})
  })
  $(document).on('mouseup',()=>{
    isDrag = false;
    $floatBox.css('cursor','move');
  })
})
