import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs'

function initMermaid() {
    mermaid.initialize(
        { 
            startOnLoad: true, 
            theme: "neutral",
            fontSize: '16px',
            look: "handDrawn", 
            sequence: {showSequenceNumbers: true},
            fontFamily: "system-ui",
            forceLegacyMathML: true
        }
    )
}

initMermaid()