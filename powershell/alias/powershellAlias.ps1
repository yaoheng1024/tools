function showLog {
  param([string] $msg)
  Write-Host $msg -ForegroundColor Green
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
  $gitStatus = git status
  if (!($gitStatus -match 'Changes to be committed') -and ($gitStatus -match 'Your branch and .* have diverged' -or $gitStatus -match 'Your branch is ahead of .* by')) {
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

function parseGitStatusResult {
  param ([string] $msg)
  if ($msg -match 'Your branch is behind') {

  }
}

function pull {
  showLog "开始从远端获取最新的代码信息"
  git fetch
  $gitStatus = git status
  if ($gitStatus -match 'Your branch is behind' -or $gitStatus -match 'Your branch and .* have diverged') {
    showLog "当前分支与远端分支有提交交叉，准备使用rebase更新代码"
    showLog "执行stash操作"
    git stash -u
    showLog "开始从远端拉取最新的代码"
    git pull --rebase
    showLog "执行stash pop操作"
    git stash pop
  }
  else {
    git pull
  }
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