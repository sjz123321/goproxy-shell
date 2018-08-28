# goproxy-shell

goproxy服务端部署脚本
### 使用方法
`wget --no-check-certificate https://github.com/sjz123321/goproxy-shell/releases/download/v0.1.1_fixed/install_fixed.sh && bash install_fixed.sh`

之后使用在命令行中输入 `run_goproxy.sh` 即可

## 版本号及说明
v0.2.1

更新：

增加了socks下的kcp传输协议，增加了卸载功能。

v0.2.0

更新： 

1.在服务端部署成功后自动生成用户端需要输入的命令 

2.更新了本机ip获取机制，避免反复获取浪费时间，对于无法自动获取ip的vps现在可以手动输入了。


v0.1.1

现有功能：

1.http代理包括 kcp tcp socks 含有或不含有tls加密的部署

2.tls证书生成

3.命令行杂项设置

4.tls证书回传

5.开机自启

尚未完成的功能：

1.多级代理

2.非http代理均未完成



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
