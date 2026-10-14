import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs'

function initMermaid() {
    mermaid.initialize(
        { 
            startOnLoad: true, 
            theme: "neutral",
            look: "handDrawn", 
            fontFamily: "system-ui",
            forceLegacyMathML: true
        }
    )
}

initMermaid()