set windows-shell := ["powershell", "-Command"]

run-win:
  ./windows-luau/luau.exe --profile ./EPBBCodeEdgecases.luau

run-win-profiler:
  ./windows-luau/luau.exe --profile ./EPBBCodeProfiler.luau

run-linux:
  ./linux-luau/luau --profile ./EPBBCodeEdgecases.luau

run-linux-profiler:
  ./linux-luau/luau.exe --profile ./EPBBCodeProfiler.luau

run-nix:
  luau --profile ./EPBBCodeEdgecases.luau

run-nix-profiler:
  luau --profile ./EPBBCodeProfiler.luau

format-nix:
  stylua EPBBCodeEdgecases.luau
  stylua EPBBCode.luau

format-win:
  ./windows-luau/stylua EPBBCode.luau
  /.windows-luau/stylua EPBBCodeProfiler.luau
  ./windows-luau/stylua EPBBCodeEdgecases.luau