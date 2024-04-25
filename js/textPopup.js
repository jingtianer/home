var colors = new Array("#FF0000","#FF7F00"," #FFFF00","#00FF00","#00FFFF","#0000FF","#8B00FF","#FF0000","#FF7F00"," #FFFF00","#00FF00","#00FFFF","#0000FF","#8B00FF");
var fnTextPopup = function (arr, options) {
    // arr参数是必须的
    if (!arr || !arr.length) {
        return;
    }
    // 主逻辑
    var index = 0;
    document.documentElement.addEventListener('click', function (event) {
        var x = event.pageX, y = event.pageY;
        var eleText = document.createElement('span');
        eleText.className = 'text-popup';
        this.appendChild(eleText);
        if (arr[index]) {
            eleText.innerHTML = arr[index];
        } else {
            index = 0;
            eleText.innerHTML = arr[0];
        }
        // 动画结束后删除自己
        eleText.addEventListener('animationend', function () {
            eleText.parentNode.removeChild(eleText);
        });
        // 位置
        eleText.style.left = (x - eleText.clientWidth / 2) + 'px';
        eleText.style.top = (y - eleText.clientHeight) + 'px';
        //设置颜色
        eleText.style.color = colors[index%14]
        // index递增
        index++;
    });
};

fnTextPopup(['富强', '民主', '文明', '和谐', '自由', '平等', '公正', '法治', '爱国', '敬业', '诚信', '友善']);