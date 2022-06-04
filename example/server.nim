# super pre post alpha, no api wrapping

import asyncdispatch, asyncnet, nativesockets, math
import ../doodic/doodic

const MAX_DATAGRAM_SIZE = 1350

proc main {.async.} =
    let server = newDoodicServer(Port(9153))
    server.listen()    

waitFor main()