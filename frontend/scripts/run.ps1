# gradle.properties의 KAKAO_NATIVE_APP_KEY를 읽어 flutter run 실행
# 사용: .\scripts\run.ps1 또는 .\scripts\run.ps1 --release
Set-Location $PSScriptRoot\..

$gradleProps = Get-Content "android\gradle.properties" -ErrorAction SilentlyContinue
$kakaoKey = ""
foreach ($line in $gradleProps) {
    if ($line -match '^\s*KAKAO_NATIVE_APP_KEY=(.*)$') {
        $kakaoKey = $matches[1].Trim()
        break
    }
}

$dartDefines = @{ KAKAO_NATIVE_APP_KEY = $kakaoKey } | ConvertTo-Json -Compress
$dartDefines | Out-File -FilePath "dart_defines.json" -Encoding utf8

$flutterArgs = @("run", "--dart-define-from-file=dart_defines.json") + $args
& flutter @flutterArgs
