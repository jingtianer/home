// scripts/lazyimg.js
const cheerio = require('cheerio');
hexo.extend.filter.register('after_render:html', function (html) {
  const $ = cheerio.load(html);
  const cssText = `
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
.global-blur{
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
.navbar-menu {
  background: transparent !important;
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
  $('.navbar').addClass('global-blur')
  $('.pagination-previous').addClass('global-blur')
  $('.pagination-next').addClass('global-blur')
  $('.pagination-link').addClass('global-blur')
  $('#back-to-top').addClass('global-blur')
  $('.footer').addClass('card')
  $('.gt-header-textarea').addClass('global-blur')
  $('.tag').addClass('global-blur')
  $('.tags .tag').removeClass('global-blur').addClass('hljs')
  $('.article-licensing').addClass('global-blur')
  $('table').addClass('hljs')

  return $.html();
});