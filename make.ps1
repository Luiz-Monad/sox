
# pre
Push-Location $PSScriptRoot
$out = '../sox-build/sox'
$build = (New-Item -ItemType Directory $out -Force).FullName
$bin = (New-Item -ItemType Directory $out/../bin -Force).FullName
$ogg = (Get-Item "$bin/lib/cmake/ogg").FullName
$flac = (Get-Item "$bin/lib/cmake/flac").FullName

$vswhere = "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe"
$msbuild = & $vswhere -latest -requires Microsoft.Component.MSBuild -find "MSBuild\**\Bin\MSBuild.exe"
$cmake = & $vswhere -latest -requires Microsoft.VisualStudio.Component.VC.CMake.Project -find "Common7\IDE\CommonExtensions\Microsoft\CMake\**\bin\cmake.exe"

# make
& $cmake . -B $build "-DOgg_DIR=$ogg" "-Dflac_DIR=$flac"

# build

# & $cmake --build $build --target install "-DCMAKE_BUILD_TYPE=Release" "-DCMAKE_INSTALL_PREFIX=$bin"
& $msbuild $build/sox.sln -maxCpuCount:16 -p:Configuration=Release -detailedSummary
& $cmake --install $build --prefix $bin

# done
Pop-Location
