# 网易云音乐海外解锁(Windows)



## 一. 使用方法

1. 下载并安装[Mitmproxy](https://mitmproxy.org/)

2. 修改网易云音乐代理为(端口冲突请自行更换)

   ![image-20250228230317522](./Photo/image-20250228230317522.png)

3. 下载HelloWorld.ps1，将其移动到合适的位置后运行(运行后会生成一个文件，每次运行时都需要调用)
4. 重启电脑，如果安装成功则会在开机后自动后台运行，直接打开网易云音乐测试即可



## 二. 原理

使用Mitmproxy拦截网易云音乐的请求，修改请求头的X-Real-IP为国内IP，从而解锁网易云音乐的海外限制

通过计划任务，每次开机时自动运行Mitmproxy



## 三. 已知问题

1. 部分笔记本电脑在未插电的情况下无法启动计划任务，需要自己手动启动