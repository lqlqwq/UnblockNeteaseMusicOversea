# ��Ȩ
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    $scriptPath = $MyInvocation.MyCommand.Definition
    $arguments = "-File `"$scriptPath`""
    Start-Process powershell -Verb RunAs -ArgumentList $arguments
    exit
}

# -------------------------------
# ���񲿷�
# -------------------------------

# �����ļ�
@'
from mitmproxy import http

# ��Ҫ���ص�����
TARGET_DOMAINS = ["p4.music.126.net", "p3.music.126.net","music.163.com"]

def request(flow: http.HTTPFlow):
    """��������"""
    if any(domain in flow.request.url for domain in TARGET_DOMAINS):
        # print("���ص�����: {flow.request.url}")

        flow.request.headers["X-Real-IP"] = "182.138.156.158"
        flow.request.headers["X-Forwarded-For"] = "182.138.156.158"

        # print(flow.request.headers["X-Real-IP"])

        # �޸���������۸� User-Agent
        # flow.request.headers["User-Agent"] = "Custom-Proxy-User-Agent"

        # Ҳ����ֱ�ӷ����Զ�����Ӧ
        # flow.response = http.Response.make(
        #     200,  # ״̬��
        #     b'{"message": "���سɹ�"}',  # ��Ӧ��
        #     {"Content-Type": "application/json"}  # ��Ӧͷ
        # )
'@ | Set-Content -Path "$PSScriptRoot\intercept_netease.py" -Encoding UTF8

# ɾ��-WindowStyle Hidden���Ե���(��������޷���������)
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command `
    `"if (Get-Process -Name 'mitmdump' -ErrorAction SilentlyContinue) { `
        Write-Output 'mitmdump �Ѿ���������.'; `
    } else { `
        Start-Process mitmdump -ArgumentList '-s $PSScriptRoot\intercept_netease.py' -NoNewWindow; `
        Write-Output '���гɹ�.'; `
    } `
    Write-Output '���ڽ��������ر�.'; `
    Start-Sleep -Seconds 3; exit;`""

# �ӳ� 10 �������
$trigger = New-ScheduledTaskTrigger -AtStartup
$trigger.Delay = "PT10S"   

# ǿ�����д�������ֹ�Դ���
$ErrorActionPreference = "Stop"  

try {
    Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "NeteaseMusic" -Description "NeteaseMusicUnblock" -RunLevel Highest
    
    Write-Host "�ƻ����񴴽��ɹ������ڽ���3s��ر�"
    Start-Sleep -Seconds 3
} catch {
    Write-Host "���񴴽�ʧ�ܣ�" $_.Exception.Message
    Start-Sleep -Seconds 3
}
