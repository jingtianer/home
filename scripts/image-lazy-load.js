// scripts/lazyimg.js
const cheerio = require('cheerio');
hexo.extend.filter.register('after_render:html', function (html) {
  const $ = cheerio.load(html);
  // 修正：class选择器 .galleria，不是标签 galleria
  const gallerias = $('.galleria');

  const cssText = `
.global-lazy-loading-img{ 
    width: 1.28em; 
    height: 1.28em;
    font-size: 100%;
}
.lazy-galleria{ 
    width: 100%; 
    height: 100dvh; 
}
.galleria-stage {
  top: 0px !important;
  bottom: 0px !important;
  left: 0px !important;
  right: 0px !important;
  width: 100% !important;
  height: 100% !important;
}
.card{
  backdrop-filter: blur(12px) !important;
  -webkit-backdrop-filter: blur(12px) !important; /* Safari兼容 */

  /* 半透底色，必不可少 */
  background: rgba(255,255,255, 0.3) !important;

  /* 可选：细微边框提升质感 */
  border: 1px solid rgba(255,255,255,0.25) !important;
  border-radius: 12px !important;
  color: #000 !important;
}
.gt-header-textarea{
  backdrop-filter: blur(12px) !important;
  -webkit-backdrop-filter: blur(12px) !important; /* Safari兼容 */

  /* 半透底色，必不可少 */
  background: rgba(255,255,255, 0.3) !important;

  /* 可选：细微边框提升质感 */
  border: 1px solid rgba(255,255,255,0.25) !important;
  border-radius: 12px !important;
}
.menu-list a.is-active{
  backdrop-filter: blur(12px) !important;
  -webkit-backdrop-filter: blur(12px) !important; /* Safari兼容 */

  /* 半透底色，必不可少 */
  background: rgba(255,255,255, 0.3) !important;

  /* 可选：细微边框提升质感 */
  border: 1px solid rgba(255,255,255,0.25) !important;
  border-radius: 12px !important;
}
.menu-list a:hover{
  backdrop-filter: blur(12px) !important;
  -webkit-backdrop-filter: blur(12px) !important; /* Safari兼容 */

  /* 半透底色，必不可少 */
  background: rgba(255,255,255, 0.3) !important;
  background-color: rgba(255,255,255, 0.3) !important;

  /* 可选：细微边框提升质感 */
  border: 1px solid rgba(255,255,255,0.25) !important;
  border-radius: 12px !important;
}
.navbar {
margin: 1em !important;
backdrop-filter: blur(12px) !important;
-webkit-backdrop-filter: blur(12px) !important; /* Safari兼容 */

/* 半透底色，必不可少 */
background: rgba(255,255,255, 0.3) !important;

/* 可选：细微边框提升质感 */
border: 1px solid rgba(255,255,255,0.25) !important;
border-radius: 12px !important;
color: #000 !important;
}
.hljs {
  backdrop-filter: blur(12px) !important;
  -webkit-backdrop-filter: blur(12px) !important; /* Safari兼容 */

  /* 半透底色，必不可少 */
  background: rgba(255,255,255, 0.3) !important;
}
.button{
  backdrop-filter: blur(12px) !important;
  -webkit-backdrop-filter: blur(12px) !important; /* Safari兼容 */

  /* 半透底色，必不可少 */
  // opacity: 0.8;
  margin-left: 0.1em !important;
  margin-right: 0.1em !important;
  /* 可选：细微边框提升质感 */
  border: 1px solid rgba(255,255,255,0.25) !important;
  border-radius: 12px !important;
}
body {
  background: linear-gradient(90deg, #CAEFD7ee, #F5BFD7ee, #ABC9E9ee) !important;
}
.navbar-link.is-active:hover {
  backdrop-filter: blur(12px) !important;
  -webkit-backdrop-filter: blur(12px) !important; /* Safari兼容 */

  /* 半透底色，必不可少 */
  background: rgba(255,255,255, 0.3) !important;
  background-color: transparent !important;
  margin-left: 0.1em !important;
  margin-right: 0.1em !important;
  /* 可选：细微边框提升质感 */
  border: 1px solid rgba(255,255,255,0.25) !important;
  border-radius: 12px !important;
  color: #000 !important;
}
.content blockquote{
  backdrop-filter: blur(12px) !important;
  -webkit-backdrop-filter: blur(12px) !important; /* Safari兼容 */

  /* 半透底色，必不可少 */
  background: rgba(255,255,255, 0.3) !important;
}
.footer {
  margin: 1em !important;
}
.widget .tags .tag:first-child {
  color: #000 !important;
}
.pagination-link.is-current {
  color: #000 !important;
  font-weight: 600 !important;
}
.timeline .media:last-child:after{
  background: transparent !important;
}
`;
  // 注入样式
  $('<style>').text(cssText).appendTo('head');
  $('.navbar').addClass('card')
  $('.pagination-previous').addClass('card')
  $('.pagination-next').addClass('card')
  $('.pagination-link').addClass('card')
  $('#back-to-top').addClass('card')
  $('.footer').addClass('card')
  $('.gt-header-textarea').addClass('card')
  $('.tag').addClass('card')
  $('.tags .tag').removeClass('card').addClass('hljs')
  $('.article-licensing').addClass('card')
  $('table').addClass('hljs')
  gallerias.each(function () {
    const $galleria = $(this);
    // 查找容器内部所有img，打上标记，跳过后续处理
    $galleria.find("img").each(function () {
      const $img = $(this);
      if ($img.attr('data-processed')) return;

      $img.attr('data-processed', '1');
      $img.attr('loading', 'lazy');

      const realSrc = $img.attr('src');
      $img.attr('galleria-src', realSrc);
      $img.attr('src', "/home/images/loading.gif");
      $img.addClass('global-lazy-loading-img');
    })
    $galleria.addClass('lazy-galleria');
    $galleria.removeClass('galleria');
  })

  const imgs = $('img');
  imgs.each(function () {
    const $img = $(this);
    // 跳过已经标记的图片（galleria里面的img会直接在这里return）
    if ($img.attr('data-processed')) return;

    const loadingAttr = ($img.attr('loading') || "").toLocaleLowerCase();
    const isEager = loadingAttr === 'eager';

    const realSrc = $img.attr('src');
    $img.attr('data-processed', '1');
    $img.attr('data-src', realSrc);

    if (!isEager) {
      $img.attr('loading', 'lazy');
      $img.attr('src', "/home/images/loading.gif");
      $img.addClass('global-lazy-loading-img');
    }
  })

  return $.html();
});