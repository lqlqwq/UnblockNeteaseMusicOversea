# 提权
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    $scriptPath = $MyInvocation.MyCommand.Definition
    $arguments = "-File `"$scriptPath`""
    Start-Process powershell -Verb RunAs -ArgumentList $arguments
    exit
}

# -------------------------------
# 任务部分
# -------------------------------

# 创建文件
@'
from mitmproxy import http

# 需要拦截的域名
TARGET_DOMAINS = ["p4.music.126.net", "p3.music.126.net","music.163.com"]

def request(flow: http.HTTPFlow):
    """拦截请求"""
    if any(domain in flow.request.url for domain in TARGET_DOMAINS):
        # print("拦截到请求: {flow.request.url}")

        flow.request.headers["X-Real-IP"] = "182.138.156.158"
        flow.request.headers["X-Forwarded-For"] = "182.138.156.158"

        # print(flow.request.headers["X-Real-IP"])

        # 修改请求，例如篡改 User-Agent
        # flow.request.headers["User-Agent"] = "Custom-Proxy-User-Agent"

        # 也可以直接返回自定义响应
        # flow.response = http.Response.make(
        #     200,  # 状态码
        #     b'{"message": "拦截成功"}',  # 响应体
        #     {"Content-Type": "application/json"}  # 响应头
        # )
'@ | Set-Content -Path "$PSScriptRoot\intercept_netease.py" -Encoding UTF8

# 删除-WindowStyle Hidden可以调试(如果发现无法正常运行)
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command `
    `"if (Get-Process -Name 'mitmdump' -ErrorAction SilentlyContinue) { `
        Write-Output 'mitmdump 已经在运行中.'; `
    } else { `
        Start-Process mitmdump -ArgumentList '-s $PSScriptRoot\intercept_netease.py' -NoNewWindow; `
        Write-Output '运行成功.'; `
    } `
    Write-Output '窗口将在三秒后关闭.'; `
    Start-Sleep -Seconds 3; exit;`""

# 延迟 10 秒后启动
$trigger = New-ScheduledTaskTrigger -AtStartup
$trigger.Delay = "PT10S"   

# 强制所有错误变成终止性错误
$ErrorActionPreference = "Stop"  

try {
    Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "NeteaseMusic" -Description "NeteaseMusicUnblock" -RunLevel Highest
    
    Write-Host "计划任务创建成功！窗口将在3s后关闭"
    Start-Sleep -Seconds 3
} catch {
    Write-Host "任务创建失败：" $_.Exception.Message
    Start-Sleep -Seconds 3
}
