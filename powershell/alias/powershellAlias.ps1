function showLog {
  param([string] $msg)
  Write-Host $msg -ForegroundColor Green
}

function isWorkingTreeClean {
  $gitStatus = git status
  if ($gitStatus -match 'working tree clean') {
    return $true;
  }
  return $false
}

function isBranchBehindOrDiverged {
  $gitStatus = git status
  if ($gitStatus -match 'Your branch is behind' -or $gitStatus -match 'Your branch and .* have diverged') {
    return $true
  }
  return $false;
}

function isBranchUpToDate {
  $gitStatus = git status
  if ($gitStatus -match 'Your branch is up to date') {
    return $true
  }
  return $false
}

function hasCommitsToPush {
  $gitStatus = git status
  if (!($gitStatus -match 'Changes to be committed') -and ($gitStatus -match 'Your branch and .* have diverged' -or $gitStatus -match 'Your branch is ahead of .* by')) {
    return $true;
  }
  return $false
}

# 提交bug
function _cm {
  param([string] $commitMsg, [bool] $skipVerify)
  showLog "git commit -m `"$commitMsg`""
  if ($skipVerify) {
    git commit -m $commitMsg --no-verify
    return;
  }
  git commit -m $commitMsg
}

function cmb {
  param([string] $id, [string] $msg, [bool] $skipVerify)
  $commitMsg = "fix(otl$id): $msg"
  _cm $commitMsg $skipVerify
}
function cmbAndPush {
  param([string] $id, [string] $msg, [bool] $skipVerify)
  cmb $id $msg $skipVerify
  git status
  if (hasCommitsToPush -eq $true) {
    return push;
  }
  showLog("commit失败了")
}
# 提交feature
function cmf {
  param([string] $msg, [bool] $skipVerify)
  $commitMsg = "feat(otl): $msg"
  _cm $commitMsg $skipVerify
}

function cmfAndPush {
  param([string] $msg, [bool] $skipVerify)
  cmf $msg $skipVerify
  git status
  if (hasCommitsToPush -eq $true) {
    return push;
  }
  showLog("commit失败了")
}

function parseGitStatusResult {
  param ([string] $msg)
  if ($msg -match 'Your branch is behind') {

  }
}

function pull {
  showLog "开始从远端获取最新的代码信息"
  git fetch
  if (isBranchUpToDate -eq $true) {
    showLog "当前分支已经是最新的代码，无需更新"
    return $true;
  }
  if (isBranchBehindOrDiverged -eq $false) {
    $pullResult = git pull
    if ($pullResult -match 'CONFLICT') {
      showLog "拉取代码时发生冲突，请手动解决冲突后再次执行pull操作"
      return $false;
    }
    return $true;
  }
  showLog "当前分支与远端分支有提交交叉，准备使用rebase更新代码"
  $isClean = isWorkingTreeClean
  if ($isClean -eq $false) {
    showLog "有未提交的内容，为避免冲突，执行stash操作"
    git stash -u
  }
  showLog "开始从远端拉取最新的代码"
  $pullResult = git pull --rebase
  if ($pullResult -match 'CONFLICT') {
    showLog "拉取代码时发生冲突，请手动解决冲突后再次执行pull操作"
    return $false;
  }
  if ($isClean -eq $false) {
    showLog "恢复stash的文件"
    git stash pop
  }
  return $true;
}

function push {
  pull
  showLog "开始推送代码到远端"
  git push
}

function resetToPrevCommit {
  param([bool] $isHard)
  if ($isHard) {
    git reset --hard HEAD^
  }
  else {
    git reset --soft HEAD^
  }
}

function resetToBranch {
  param([string] $branch)
  git fetch
  git reset --hard origin/$branch
}

function merge {
  param([string] $branch)
  git fetch
  git pull origin $branch
}

function deleteBranch {
  param([string] $branch)
  git branch -d $branch
  git push origin --delete $branch
}

function buildOtl {
  showLog "开始打包wpsweb..."
  cd D:\workspace\wpsweb\client\app
  node --stack-size=8092 --max-old-space-size=8092 ./node_modules/gulp/bin/gulp.js --sourcemap --outline
}

function startWst {
  showLog "启动whistle..."
  w2 start -n pyh_whistle -w pyh159357
}

function startClipboardMonitor {
  showLog "启动剪贴板监听..."
  $job = Get-Job -Name clipboardMonitor -ErrorAction Ignore
  if ($job) {
    if ("Running" -eq $job.State) {
      return
    }
    $job | Remove-Job
  }
  try {
    Start-Job -Name clipboardMonitor -FilePath $scriptRoot\powershell\clipboardMonitor.ps1
  }
  catch {
    showLog "An error occurred:"
    showLog $_
  }
}

function startWps {
  startClipboardMonitor
  startWst
  buildOtl
}