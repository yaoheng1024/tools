Write-Verbose -Message "开始监控剪贴板" -Verbose
# 创建一个无限循环，监视剪贴板的变化
while ($true) {
    # 获取当前剪贴板的内容
    $clipboardData = Get-Clipboard -Raw
    $newClipboardData = ""
    Write-Verbose -Message $clipboardData -Verbose
    
    # 从vscode到浏览器
    if ($clipboardData -match '^client.app.applications') {
        # 浏览器里路径是以/分隔的，Windows vscode复制出来的是\，要替换掉
        $newClipboardData = $clipboardData -replace '\\', "/"
        # 打包好后的文件路径不带client/app的，所以要去掉
        $newClipboardData = $newClipboardData -replace 'client/app', ""
        # 去掉空格后的版本号
        $newClipboardData = $newClipboardData -replace ' .*', ""
    } elseif ($clipboardData -match '^webpack(?:-internal)?:/*applications') {
        # 从浏览器到vscode
        $newClipboardData = $clipboardData -replace 'webpack(?:-internal)?:/*applications/', ""
        $newClipboardData = $newClipboardData -replace '\?.*$', ""
    } elseif ($clipboardData -match '^【金山文档.+\n(https.*)') {
        # 改写金山文档分享链接格式
        $newClipboardData = $Matches.1
    }
    
    if ($newClipboardData) {
        #替换完成，写入剪贴板
        Set-Clipboard $newClipboardData
    
        # Clear-Host
        $output = "改写成功: " + $newClipboardData
        Write-Verbose -Message $output -Verbose
        # 等待一段时间再次检查剪贴板
    }
    Start-Sleep -Seconds 1
}
