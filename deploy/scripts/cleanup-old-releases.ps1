# GitHub'da v0.1.0–v0.1.7 release ve tag'lerini siler.
# Kalacaklar: v0.1.8, v0.1.9, v0.2.2
#
# Kullanim:
#   $env:GH_TOKEN = "github_pat_..."
#   powershell -File deploy\scripts\cleanup-old-releases.ps1
#
# Veya: GitHub → Actions → "Cleanup Old Releases" → Run workflow

param(
  [string]$Repo = "afmolla/flutter",
  [string]$Token = $env:GH_TOKEN
)

$Keep = @('v0.1.8', 'v0.1.9', 'v0.2.2')
$DeleteTags = @(
  'v0.1.0', 'v0.1.1', 'v0.1.2', 'v0.1.3', 'v0.1.4',
  'v0.1.5', 'v0.1.6', 'v0.1.7'
)

if (-not $Token) {
  Write-Host "GH_TOKEN yok. Actions'tan calistir: Cleanup Old Releases → Run workflow"
  exit 1
}

$Headers = @{
  Authorization = "Bearer $Token"
  Accept        = "application/vnd.github+json"
  'X-GitHub-Api-Version' = '2022-11-28'
}

$Base = "https://api.github.com/repos/$Repo"
$releases = Invoke-RestMethod -Uri "$Base/releases?per_page=100" -Headers $Headers

foreach ($r in $releases) {
  if ($Keep -contains $r.tag_name) {
    Write-Host "Keep: $($r.tag_name)"
    continue
  }
  Write-Host "Delete release: $($r.tag_name)"
  Invoke-RestMethod -Method Delete -Uri "$Base/releases/$($r.id)" -Headers $Headers
}

foreach ($tag in $DeleteTags) {
  try {
    Invoke-RestMethod -Method Delete -Uri "$Base/git/refs/tags/$tag" -Headers $Headers
    Write-Host "Deleted tag: $tag"
  } catch {
    Write-Host "Tag $tag : $($_.Exception.Message)"
  }
}

Write-Host "Done. Kalan release'ler: $($Keep -join ', ')"
