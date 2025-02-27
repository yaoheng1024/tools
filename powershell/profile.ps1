Import-Module posh-git
Import-Module PSReadLine
// 本代码目录的位置
$scriptRoot = "D:\workspace\tools"
# 遍历目录导入脚本
try {
  Get-ChildItem -Path $scriptRoot\powershell\alias\*.ps1 | ForEach-Object -Process{
    Import-Module -Name $_.FullName
  }
}
catch {
  Write-Host "An error occurred:"
  Write-Host $_
}


# 设置paradox主题，如果要更换，替换名字即可
# 使用 Get-PoshThemes 查看所有主题
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\paradox.omp.json" | Invoke-Expression

# Set Hot-keys BEGIN
# 设置预测文本来源为历史记录
Set-PSReadLineOption -PredictionSource History

# 每次回溯输入历史，光标定位于输入内容末尾
Set-PSReadLineOption -HistorySearchCursorMovesToEnd

# 设置 Tab 为菜单补全和 Intellisense
Set-PSReadLineKeyHandler -Key "Tab" -Function MenuComplete

# 设置 Ctrl+d 为退出 PowerShell
Set-PSReadlineKeyHandler -Key "Ctrl+d" -Function ViExit

# 设置 Ctrl+z 为撤销
Set-PSReadLineKeyHandler -Key "Ctrl+z" -Function Undo

# 设置向上键为后向搜索历史记录
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward

# 设置向下键为前向搜索历史纪录
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
# Set Hot-keys END 

