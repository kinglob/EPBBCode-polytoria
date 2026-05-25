set windows-shell := ["powershell", "-Command"]

run:
  ./windows-luau/luau.exe --profile ./EPBBCodeTest.luau

run-win:
  ./windows-luau/luau.exe --profile ./EPBBCodeTest.luau

run-linux:
  ./linux-luau/luau --profile ./EPBBCodeTest.luau

run-nix:
  luau --profile ./EPBBCodeTest.luau

format:
  stylua EPBBCodeTest.luau
  stylua EPBBCode.luau
