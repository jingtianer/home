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
    height: calc(100dvh - var(--nav-height) - 2em); 
}
.galleria-stage {
  top: 0px !important;
  bottom: 0px !important;
  left: 0px !important;
  right: 0px !important;
  width: 100% !important;
  height: 100% !important;
}
`;
  // 注入样式
  $('<style>').text(cssText).appendTo('head');
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

  const imgs = $('img:not([data-processed]), img[data-processed]:not([data-processed="1"])');
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