# goproxy-shell

goproxy服务端部署脚本
### 使用方法
`wget --no-check-certificate https://github.com/sjz123321/goproxy-shell/releases/download/v0.1.0/install.sh && bash `

之后使用在命令行中输入 `run_goproxy.sh` 即可

## 版本号及说明
v0.1.0 demo

现有功能：

1.http代理包括 kcp tcp socks 含有或不含有tls加密的部署

2.tls证书生成

3.命令行杂项设置

尚未完成的功能：

1.多级代理

2.非http代理均未完成

3.多proxy任务开机启动

4.tls证书回传

下一步会逐步完善这些功能

## 界面展示

#### 脚本主界面
![1.1](/pic/main.jpg) 
#### tcp设置界面
![1.2](/pic/tcp.jpg) 
#### kcp设置界面
![1.3](/pic/kcp.jpg) 
#### socks设置界面
![1.4](/pic/socks.jpg) 

## 常见的问题
#### 关于中文无法正常显示的问题

ssh端中文无法正常显示。请检查系统环境变量运行 env 查看 LANG=en_US.UTF-8 如果不为这个值。请运行 export LANG=en_US.UTF-8

如果仍然不正常请检查 （以debian ubuntu为例） dpkg-reconfigure locales 在第一个选项卡中选择 en_US.UTF-8 zh.CN.UTF-8

并在第二个选项卡中选择en_US.UTF-8作为默认语言。

关于运行export LANG=en_US.UTF-8 后中文显示正常，但重启之后又不正常的解决方案

在 /etc/profile 文件中增加一行 export LANG=en_US.UTF-8 使其变为系统环境变量即可。
