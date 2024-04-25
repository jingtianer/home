

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
    var buttons = document.getElementsByClassName("button")
    for (let i = 0; i < buttons.length; i++) {
        if (buttons[i].getAttribute("title") == "RSS") {
            var url = document.baseURI + "atom.xml"
            buttons[i].href = "javascript:;"
            buttons[i].target = "_self"
            buttons[i].setAttribute('onclick', "copyToClipboard(\"" + url + "\", function() { alert(\"Copied to clipboard!\") })")
            break
        }
    }
})



function copyCode(element) {
    if (element instanceof Element) {
        var elemt = element
        while(elemt.tagName != "FIGURE") {
            elemt = elemt.parentElement
        }
        elemt = elemt.getElementsByClassName("code")[0]
        
        var text =elemt.innerText
        
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

