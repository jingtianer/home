document.addEventListener('DOMContentLoaded', function () {
    const concurrencyLimit = 3;
    const pool = [];

    async function scheduleImageLoad(imgs) {
        if (imgs.length === 0) return;

        for (const imgEl of imgs) {
            // 防止重复加载
            if (imgEl.dataset.globalLazyloaded) continue;
            const url = imgEl.dataset.src;
            if (!url) continue;

            // 单个图片加载任务
            const loadTask = new Promise((resolve) => {
                const tempImg = new Image();
                tempImg.crossOrigin = "anonymous";
                tempImg.src = url;

                tempImg.onload = () => {
                    resolve({ ok: true, el: imgEl, url });
                };
                tempImg.onerror = () => {
                    console.warn('图片预加载失败：', url);
                    resolve({ ok: false, el: imgEl, url });
                };
            });

            // 并发控制：池满了就等其中一个完成
            if (pool.length >= concurrencyLimit) {
                await Promise.race(pool);
            }
            pool.push(loadTask);

            loadTask.then((res) => {
                if (res.ok) {
                    const el = res.el;
                    el.src = url;
                    el.dataset.globalLazyloaded = "1";
                    el.classList.remove('global-lazy-loading-img');
                    if (el.parentElement && el.parentElement.tagName === 'A') {
                        el.parentElement.href = url;
                    }
                } else {
                    const el = res.el;
                    onLazyLoadFailed(el);
                }
            }).finally(() => {
                // 无论成功失败，都从并发池移除
                const idx = pool.indexOf(loadTask);
                if (idx > -1) pool.splice(idx, 1);
            });
        }
    }

    // 获取所有图片
    const imgs = document.querySelectorAll('img');

    function onLazyLoadFailed(img) {
        img.src = img.dataset.src;
        img.classList.remove('global-lazy-loading-img');
        img.dataset.globalLazyloaded = "1";
    }

    // 交叉观察器，进入视口前200px触发加载
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const targetImg = entry.target;
                if (targetImg.src && targetImg.src.startsWith("/home")) {
                    scheduleImageLoad([targetImg]);
                } else {
                    onLazyLoadFailed(targetImg);
                }
                observer.unobserve(targetImg);
            }
        });
    }, {
        rootMargin: '200px 0px',
        threshold: 0.01
    });

    function handleImg(img) {
        // eager加载的图片跳过
        if (img.loading?.toLowerCase() === "eager") return;
        // 没有data-src的跳过
        if (!img.dataset.src) return;
        observer.observe(img);
    }

    // 初始化页面已有图片
    imgs.forEach(img => handleImg(img));

    // 监听动态新增DOM（AJAX/JS插入图片）
    const mo = new MutationObserver((mutations) => {
        for (const mut of mutations) {
            mut.addedNodes.forEach(node => {
                if (node.tagName && node.tagName.toLowerCase() === 'img') {
                    handleImg(node);
                    return;
                }
                if (node.querySelectorAll) {
                    const imgs = node.querySelectorAll('img');
                    imgs.forEach(img => handleImg(img));
                }
            });
        }
    });

    mo.observe(document.body, {
        childList: true,
        subtree: true
    });

    // 页面卸载清理，防止内存泄漏
    window.addEventListener('beforeunload', () => {
        mo.disconnect();
        observer.disconnect();
    });
});

document.addEventListener('DOMContentLoaded', function () {
    const $galleriaList = document.querySelectorAll('.lazy-galleria');
    if ($galleriaList.length === 0) return; // 没有图库容器，直接退出，不加载资源

    // 加载脚本工具函数，串行加载
    function loadScript(url) {
        return new Promise((resolve, reject) => {
            const script = document.createElement('script');
            script.src = url;
            script.onload = resolve;
            script.onerror = reject;
            document.body.appendChild(script);
        });
    }

    function recoverImgSrc(el, url) {
        el.src = url;
        el.classList.remove('global-lazy-loading-img')
        if (el.parentElement && el.parentElement.tagName === 'A') {
            el.parentElement.href = url;
        }
    }

    async function loadGalleriaImages(gallery, galleryList) {
        if (galleryList.length <= 0) {
            return
        }
        gallery.splice(1, galleryList.length)
        function appendImage(url) {
            gallery.push({ image: url });
        }
        for (const url of galleryList) {
            if (!url) {
                appendImage('/home/images/picture-loading-failed.png');
                continue;
            }
            appendImage(url);
        }
    }

    async function loadGalleriaLib() {
        try {
            await loadScript('https://cdnjs.cloudflare.com/ajax/libs/galleria/1.5.7/galleria.min.js');
            Galleria.loadTheme('https://cdnjs.cloudflare.com/ajax/libs/galleria/1.5.7/themes/classic/galleria.classic.min.js');
        } catch (err) {
            console.error('Galleria 脚本加载失败', err);
        }
    }

    function getImageList(galleria) {
        const imgs = Array.from(galleria.querySelectorAll('img[galleria-src]'));
        if (imgs.length <= 0) {
            return []
        }
        const firstImg = imgs[0]
        recoverImgSrc(imgs[0], firstImg.getAttribute('galleria-src')) // 第一张图默认展示，否则galleria有bug，无法更新封面图
        return imgs.slice(1).map(function (value, index, array) {
            return value.getAttribute('galleria-src') || '/home/images/loading.gif';
        });
    }

    async function lazyLoadImages() {
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const galleria = entry.target;
                    const index = galleria.dataset.index || 0
                    const galleriaName = "lazy-galleria-" + index
                    galleria.classList.add(galleriaName)
                    const galleryList = getImageList(galleria);
                    Galleria.run('.' + galleriaName, {
                        extend: function () {
                            var gallery = this;
                            $(galleria).click(function () {
                                gallery.toggleFullscreen();
                            });
                            gallery.bind('fullscreen_enter', function(event) {
                                gallery.play(1200)
                            })
                            gallery.bind('fullscreen_exit', function(event) {
                                gallery.pause()
                            })
                            loadGalleriaImages(gallery, galleryList)
                        },
                        thumbnails: false,
                    });
                    observer.unobserve(galleria);
                }
            });
        }, {
            threshold: 0.01
        });
        $galleriaList.forEach(function (galleria, index, arr) {
            galleria.dataset.index = index + 1
            observer.observe(galleria);
        })
    }

    loadGalleriaLib().then(lazyLoadImages).catch(e => {
        console.error("图库初始化异常", e);
    });

    // 页面卸载清理，防止内存泄漏
    window.addEventListener('beforeunload', () => {
        observer.disconnect();
    });

});