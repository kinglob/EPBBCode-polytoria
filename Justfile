set windows-shell := ["powershell", "-Command"]

run-win:
  ./windows-luau/luau.exe --profile ./EPBBCodeTest.luau

run-linux:
  ./linux-luau/luau --profile ./EPBBCodeTest.luau

run-nix:
  luau --profile ./EPBBCodeTest.luau

# i'll add linux format commands later i swear
format-nix:
  stylua EPBBCodeTest.luau
  stylua EPBBCode.luau

format-win:
  ./windows-luau/stylua EPBBCode.luau
  ./windows-luau/stylua EPBBCodeTest.luau