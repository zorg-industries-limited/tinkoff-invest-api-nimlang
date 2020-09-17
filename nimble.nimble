# Package

version       = "0.1.0"
author        = "Innokentiy Sokolov"
description   = "Tinkoff Invest Open API implementation"
license       = "MIT"
srcDir        = "src"
bin           = @["bin/example"]



# Dependencies

requires "nim >= 1.2.6"


# Tasks

task erun, "Compile & run Example":
    exec "nim compile --run --define:ssl --outdir:bin/ src/example.nim"
  
task trun, "Compile & run Tests":
    exec "nim compile --run --define:ssl --outdir:bin/ tests/tests.nim"

task fmt, "Format files":
    exec "nimpretty --indent:4 src/api/domain.nim"
    exec "nimpretty --indent:4 src/api/rest_api.nim"
    exec "nimpretty --indent:4 src/api/sandbox_api.nim"
    exec "nimpretty --indent:4 src/example.nim"
    exec "nimpretty --indent:4 tests/api/domain.nim"
    exec "nimpretty --indent:4 tests/api/test_api.nim"
    exec "nimpretty --indent:4 tests/tests.nim"