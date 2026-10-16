document.addEventListener('DOMContentLoaded', function () {
    // 拿到所有img
    const imgs = document.querySelectorAll('img');
    // 懒加载观察者
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const targetImg = entry.target;
                targetImg.src = targetImg.dataset.src;
                observer.unobserve(targetImg);
            }
        });
    }, {
        rootMargin: '200px 0px', // 提前200px开始加载
        threshold: 0.01
    });

    function handleImg(img) {
        if (img.loading.toLowerCase() == "eager") {
            // console.log("pass eager:" + img.src)
            return;
        }
        if (!img.dataset.src) {
            // console.log("pass undifined:" + img.src)
            return;
        }
        observer.observe(img)
    }

    imgs.forEach(img => {
        handleImg(img);
    });

    const mo = new MutationObserver((mutations) => {
        for (const mut of mutations) {
            // 遍历所有新增节点
            mut.addedNodes.forEach(node => {
                // 如果本身就是img标签
                if (node.tagName && node.tagName.toLowerCase() === 'img') {
                    handleImg(node);
                    return;
                }
                // 如果是容器，递归查找内部所有img
                if (node.querySelectorAll) {
                    const imgs = node.querySelectorAll('img');
                    imgs.forEach(img => {
                        handleImg(img);
                    });
                }
            })
        }
    });

    mo.observe(document.body, {
        childList: true,
        subtree: true
    });

    // 页面卸载，释放监听（防止内存泄漏）
    window.addEventListener('beforeunload', () => {
        mo.disconnect();
    })
});

document.addEventListener('DOMContentLoaded', function () {
    const $galleriaList = document.querySelectorAll('.galleria');
    if ($galleriaList.length === 0) return; // 没有图库容器，直接退出，不加载资源

    // 动态注入style
    const style = document.createElement('style');
    style.textContent = `
    .galleria{ 
        width: 100%; 
        height: 100dvh; 
    }
  `;
    document.head.appendChild(style);

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


    async function preloadGalleriaImages() {
        const imgs = Array.from(document.querySelectorAll('img[galleria-src]'));
        if (imgs.length === 0) return;

        const concurrencyLimit = 3;
        const tasks = [];
        const pool = [];

        for (const imgEl of imgs) {
            // 防止重复执行
            if (imgEl.dataset.galleriaLoaded) continue;

            const url = imgEl.getAttribute('galleria-src');
            if (!url) continue;

            // 单个图片加载Promise
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

            // 并发池控制
            if (pool.length >= concurrencyLimit) {
                await Promise.race(pool);
            }
            pool.push(loadTask);
            loadTask.then(() => {
                const idx = pool.indexOf(loadTask);
                if (idx > -1) pool.splice(idx, 1);
            });
            tasks.push(loadTask);
        }

        // 等待所有图片预加载完成
        const results = await Promise.all(tasks);

        // 全部加载完成，统一替换 src
        results.forEach(({ ok, el, url }) => {
            if (ok) {
                el.src = url;
                el.dataset.galleriaLoaded = "1";
                el.parentElement.href = url;
            }
        });
        // console.log("所有 galleria-src 图片预加载完毕，已更新src");
    }

    async function loadGalleriaLib() {
        // 串行加载 jquery -> galleria
        try {
            await loadScript('https://cdnjs.cloudflare.com/ajax/libs/galleria/1.5.7/galleria.min.js');
            Galleria.loadTheme('https://cdnjs.cloudflare.com/ajax/libs/galleria/1.5.7/themes/classic/galleria.classic.min.js');

            Galleria.run('.galleria', {
                extend: function () {
                    var gallery = this;
                    gallery.$('container').click(function () {
                        gallery.playToggle(1000).toggleFullscreen();
                    });
                }
            });
        } catch (err) {
            console.error('Galleria 脚本加载失败', err);
        }
    }

    preloadGalleriaImages().then(loadGalleriaLib).catch(e => {
            console.error("预加载或图库初始化异常", e);
        });

});