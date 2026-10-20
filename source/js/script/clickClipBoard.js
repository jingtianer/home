

function copyToClipboard(text, callBack) {
    navigator.clipboard.writeText(text).then(
        value => {
            // fulfillment
            callBack()
        }, reason => {
            // rejection
            alert("fail: " + reason)
        }
    )
}


$(document).ready(function() {
    $(".copy").click(function() {
        copyCode(this)
    })
    function handleRssButton(button) {
        var url = document.baseURI + "atom.xml"
        button.href = "javascript:;"
        button.target = "_self"
        button.setAttribute('onclick', "copyToClipboard(\"" + url + "\", function() { alert(\"Copied to clipboard!\") })")
    }

    const rssButton = $('i.fa.fa-rss').get(0).parentNode
    if (rssButton && rssButton.getAttribute("title") == "RSS") {
        handleRssButton(rssButton);
    } else {
        const buttons = document.getElementsByClassName('button')
        for (let i = 0; i < buttons.length; i++) {
            if (buttons[i].getAttribute("title") == "RSS") {
                handleRssButton(rssButton);
                break
            }
        }
    }
})



function copyCode(element) {
    if (element instanceof Element) {
        var elemt = element
        while(elemt.tagName != "FIGURE") {
            elemt = elemt.parentElement
        }
        const text = Array.from(elemt.getElementsByClassName("code")[0].getElementsByClassName('line')).map(el => el.innerText).join('\n')
        
        copyToClipboard(text, function() {
            var node = $(element.childNodes[0])
            node.attr('class', "fa fa-check")
            setTimeout(function () { 
                node.attr('class', "fas fa-copy")
             } ,1000)
        })
    } 
}

function fadeOutAndIn(node, onShow, onHide) {
    node.fadeOut(200, function() {
        onHide()
        node.fadeIn(200, function () { 
            onShow()
         })
    })
}

