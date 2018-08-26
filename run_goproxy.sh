#!/bin/bash

touch /etc/my_ip_addr.conf
ip_temp=`sed -n "1p" /etc/my_ip_addr.conf`
if [ `cat /etc/my_ip_addr.conf | wc -l` -eq "0" ] ; then
     echo "*****************************************"
     echo "   您的VPS外网ip未知，请选择获取方式"
	 echo "1.自动获取（如失败，请手动） 2.手动输入ip"
	 echo "*****************************************"
	 read temp_first
	 if [ $temp_first -eq "1" ] ; then
	     echo "正在获取vps外网ip"
	     ip_addr=`curl ifconfig.me`
		 echo $ip_addr >> /etc/my_ip_addr.conf
		 echo "获取vps外网ip成功 ip是 $ip_addr"
		 echo "如果设置错误请删除/etc/my_ip_addr 使用rm -f /etc/my_ip_addr.conf 指令"
	 elif [ $temp_first -eq "2" ] ; then
	     echo "请输入外网ip"
	     read ip_addr
		 echo $ip_addr >> /etc/my_ip_addr.conf
		 echo "设置vps外网ip成功 ip是 $ip_addr"
		 echo "如果设置错误请删除/etc/my_ip_addr 使用rm -f /etc/my_ip_addr.conf 指令"
	 fi
else
     ip_addr=$ip_temp
	 echo "您的vps外网ip为 $ip_addr"
fi


secure_para="-g $ip_addr"
bk="--daemon"
guard="--forever"
log_path="/var/log/proxy.log"
NULL=""

function run_proxy()
{
	echo $1
	proxy $1
}


echo "        欢迎使用goproxy配置脚本        "
echo "***************************************"
echo "      0.安装/更新goproxy（仅64位系统）"
echo "      1.打开http-tcp代理"
echo "      2.打开http-kcp代理"
echo "      3.打开socks5代理"
echo "      4.打开tcp代理"
echo "      5.打开udp代理"
echo "      6.删除所有proxy开机任务"
echo "      7.停止所有后台proxy服务"
echo "***************************************"
read choice
case $choice in

0) curl -L https://raw.githubusercontent.com/snail007/goproxy/master/install_auto.sh | bash
   cp proxy.service /etc 
   touch /etc/auto_run_proxy.sh
   chmod +x /etc/auto_run_proxy.sh
   echo "proxy 安装成功"
   
   
   ;;
   
   
1) secure_para_temp=$secure_para
   bk_temp=$bk
   guard_temp=$guard
   log_path_temp=$log_path
   log_para_temp="--log $log_path_temp"
   echo "***********请选择代理类型*************"
   echo "1.使用TLS加密（二级代理）2.使用TLS加密（多(>=3)级代理）"
   echo "3.不使用TLS加密（一级代理）4.不使用TLS加密（二级代理）"
   echo "5.不使用TLS加密（多（>=3）级代理）"
   echo "***************************************"
   read temp
   if [ $temp -eq "1" ] ; then
     echo "请输入TLS证书保存路径"
	 read path
	 echo "是否重新生成TLS证书"
	 echo "1.是 2.否"
	 read tempp
	 if [ $tempp -eq "1" ] ; then
         cd $path
		 rm -f proxy.crt proxy.key
         proxy keygen -C proxy 
		 echo "是否现在就回传证书 （默认为回传）"
		 echo "1.是   2.否"
		 read -t 15 tempp
		 tempp=${tempp:-1}
		 if [ $tempp -eq "1" ] ; then
		     sz proxy.crt proxy.key
		 fi
		 
     fi
     echo "***************************************"
     echo "     请输入需要使用的服务器端口号      "
     echo "***************************************"
     read port
	 echo "是否使用安全参数 -g your_VPS_IP （默认为使用）"
	 echo "1.是 2.否"
	 read -t 15 tempp
	 tempp=${tempp:-1}
	 if [ $tempp -eq "2" ] ; then
         secure_para_temp=$NULL
     fi
	 echo "是否监控proxy运行 （默认为后台，不监控）"
	 echo "1.否 2.是"
	 read -t 15 tempp
	 tempp=${tempp:-1}
	 if [ $tempp -eq "2" ] ; then
         bk_temp=$NULL
         guard_temp=$NULL
         log_path_temp=$NULL
         log_para_temp=$NULL
		 cd $path
		 echo "请在本地打开服务指令为："
		 echo "proxy http -t tcp -p ":8080" -T tls -P "$ip_addr:$port" -C proxy.crt -K proxy.key "
		 echo "#默认本地端口为8080 请将证书文件和可执行文件放置在同一目录下"
		 run_proxy "http $secure_para_temp -t tls -p "":$port"" -C $path/proxy.crt -K $path/proxy.key $guard_temp $log_para_temp $bk_temp"
		 exit 
     fi
	 echo "是否守护执行 （默认为使用）"
	 echo "1.是 2.否"
	 read -t 15 tempp
	 tempp=${tempp:-1}
	 if [ $tempp -eq "2" ] ; then
         guard_temp=$NULL
     fi
     echo "日志功能 （默认为开启 存储地址为$log_path）"
	 echo "1.是(默认地址) 2.是（自定义存储地址） 3.否"
	 read -t 15 tempp
	 tempp=${tempp:-1}
	 if [ $tempp -eq "2" ] ; then
         echo "请指定log存储地址（请确定地址有效！否则请在使用前先mkdir地址）"
		 read path_temp
		 log_path_temp=$path_temp
		 log_para_temp="--log $log_path_temp"
	 elif [ $tempp -eq "3" ] ; then
	     log_para_temp=""
	 fi
	 echo "是否加入开机自启动 (默认为否)"
	 echo "1.是 2.否"
	 read -t 15 tempp
	 tempp=${tempp:-2}
	 if [ $tempp -eq "1" ] ; then
         echo "proxy "http $secure_para_temp -t tls -p "":$port"" -C $path/proxy.crt -K $path/proxy.key $guard_temp $log_para_temp $bk_temp" " >> /etc/auto_run_proxy.sh
     fi
	 cd $path
	 echo "请在本地打开服务指令为："
	 echo "proxy http -t tcp -p ":8080" -T tls -P "$ip_addr:$port" -C proxy.crt -K proxy.key "
	 echo "#默认本地端口为8080 请将证书文件和可执行文件放置在同一目录下"
	 run_proxy "http $secure_para_temp -t tls -p "":$port"" -C $path/proxy.crt -K $path/proxy.key $guard_temp $log_para_temp $bk_temp"
   elif [ $temp -eq "2" ] ; then
     echo "未完待续"
     #up_ip_addr=""
	 #trans="tls"
	 #up_para=" -T $trans -P "$up_ip_addr" "
     #echo "***********您的服务器是否有上级？***********"
	 #echo "1.有 2.没有"
	 #read tempp
	 #if [ $tempp -eq "1" ] ; then
	    # echo "请输入上级ip:端口 "
	#	 read up_ip_addr
	#	 echo "请选择上级服务器传输方式"
	#	 echo "1.tls 2.tcp 3.kcp 4.socks"
	 #fi 
   elif [ $temp -eq "3" ] ; then
     echo "***************************************"
     echo "     请输入需要使用的服务器端口号      "
     echo "***************************************"
     read port
	 echo "是否使用安全参数 -g your_VPS_IP （默认为使用）"
	 echo "1.是 2.否"
	 read -t 15 tempp
	 tempp=${tempp:-1}
	 if [ $tempp -eq "2" ] ; then
         secure_para_temp=$NULL
     fi
	 echo "是否监控proxy运行 （默认为后台，不监控）"
	 echo "1.否 2.是"
	 read -t 15 tempp
	 tempp=${tempp:-1}
	 if [ $tempp -eq "2" ] ; then
         bk_temp=$NULL
         guard_temp=$NULL
         log_path_temp=$NULL
         log_para_temp=$NULL
		 cd $path
		 run_proxy "http $secure_para_temp -t tcp -p "":$port"" $guard_temp $log_para_temp $bk_temp"
		 exit 
     fi
	 echo "是否守护执行 （默认为使用）"
	 echo "1.是 2.否"
	 read -t 15 tempp
	 tempp=${tempp:-1}
	 if [ $tempp -eq "2" ] ; then
         guard_temp=$NULL
     fi
     echo "日志功能 （默认为开启 存储地址为$log_path）"
	 echo "1.是(默认地址) 2.是（自定义存储地址） 3.否"
	 read -t 15 tempp
	 tempp=${tempp:-1}
	 if [ $tempp -eq "2" ] ; then
         echo "请指定log存储地址（请确定地址有效！否则请在使用前先mkdir地址）"
		 read path_temp
		 log_path_temp=$path_temp
		 log_para_temp="--log $log_path_temp"
	 elif [ $tempp -eq "3" ] ; then
	     log_para_temp=""
	 fi
	 echo "是否加入开机自启动 (默认为否)"
	 echo "1.是 2.否"
	 read -t 15 tempp
	 tempp=${tempp:-2}
	 if [ $tempp -eq "1" ] ; then
         echo "proxy "http $secure_para_temp -t tcp -p ""0.0.0.0:$port"" $guard_temp $log_para_temp $bk_temp" " >> /etc/auto_run_proxy.sh
     fi
	 cd $path
	 run_proxy "http $secure_para_temp -t tcp -p ""0.0.0.0:$port"" $guard_temp $log_para_temp $bk_temp"
   elif [ $temp -eq "4" ] ; then
     echo "***************************************"
     echo "     请输入需要使用的服务器端口号      "
     echo "***************************************"
     read port
	 echo "是否使用安全参数 -g your_VPS_IP （默认为使用）"
	 echo "1.是 2.否"
	 read -t 15 tempp
	 tempp=${tempp:-1}
	 if [ $tempp -eq "2" ] ; then
         secure_para_temp=$NULL
     fi
	 echo "是否监控proxy运行 （默认为后台，不监控）"
	 echo "1.否 2.是"
	 read -t 15 tempp
	 tempp=${tempp:-1}
	 if [ $tempp -eq "2" ] ; then
         bk_temp=$NULL
         guard_temp=$NULL
         log_path_temp=$NULL
         log_para_temp=$NULL
		 cd $path
		 echo "请在本地打开服务指令为："
		 echo "proxy http -p "0.0.0.0:8080" -T tcp -P "$ip_addr:$port""
	     echo "#默认本地端口为8080 "
		 run_proxy "http $secure_para_temp -t tcp -p "":$port"" $guard_temp $log_para_temp $bk_temp"
		 exit 
     fi
	 echo "是否守护执行 （默认为使用）"
	 echo "1.是 2.否"
	 read -t 15 tempp
	 tempp=${tempp:-1}
	 if [ $tempp -eq "2" ] ; then
         guard_temp=$NULL
     fi
     echo "日志功能 （默认为开启 存储地址为$log_path）"
	 echo "1.是(默认地址) 2.是（自定义存储地址） 3.否"
	 read -t 15 tempp
	 tempp=${tempp:-1}
	 if [ $tempp -eq "2" ] ; then
         echo "请指定log存储地址（请确定地址有效！否则请在使用前先mkdir地址）"
		 read path_temp
		 log_path_temp=$path_temp
		 log_para_temp="--log $log_path_temp"
	 elif [ $tempp -eq "3" ] ; then
	     log_para_temp=""
	 fi
	 echo "是否加入开机自启动 (默认为否)"
	 echo "1.是 2.否"
	 read -t 15 tempp
	 tempp=${tempp:-2}
	 if [ $tempp -eq "1" ] ; then
         echo "proxy "http $secure_para_temp -t tcp -p ""0.0.0.0:$port"" $guard_temp $log_para_temp $bk_temp" " >> /etc/auto_run_proxy.sh
     fi
	 cd $path
	 echo "请在本地打开服务指令为："
	 echo "proxy http -p "0.0.0.0:8080" -T tcp -P "$ip_addr:$port""
	 echo "#默认本地端口为8080 "
	 run_proxy "http $secure_para_temp -t tcp -p ""0.0.0.0:$port"" $guard_temp $log_para_temp $bk_temp"
   elif [ $temp -eq "5" ] ; then
     echo "未完待续"
   fi
     
   
   ;;
   
   
2) secure_para_temp=$secure_para
   bk_temp=$bk
   guard_temp=$guard
   log_path_temp=$log_path
   log_para_temp="--log $log_path_temp"
   echo "***************************************"
   echo "     请输入需要使用的服务器端口号      "
   echo "***************************************"
   read port
   echo "***************************************"
   echo "          请设置kcp传输密码            "
   echo "***************************************"
   read passwd
   echo "是否监控proxy运行 （默认为后台，不监控）"
   echo "1.否 2.是"
   read -t 15 tempp
	 tempp=${tempp:-1}
	 if [ $tempp -eq "2" ] ; then
         bk_temp=$NULL
         guard_temp=$NULL
         log_path_temp=$NULL
         log_para_temp=$NULL
		 cd $path
		 echo "请在本地打开服务指令为："
	     echo "proxy http -t tcp -p ":8080" -T kcp -P "$ip_addr:$port" --kcp-key $passwd"
	     echo "#默认本地端口为8080 "
		 run_proxy "http $secure_para_temp -t kcp -p ":$port" --kcp-key $passwd $guard_temp $log_para_temp $bk_temp"
		 exit 
     fi
   echo "是否守护执行 （默认为使用）"
   echo "1.是 2.否"
   read -t 15 tempp
   tempp=${tempp:-1}
   if [ $tempp -eq "2" ] ; then
         guard_temp=$NULL
   fi
   echo "日志功能 （默认为开启 存储地址为$log_path）"
   echo "1.是(默认地址) 2.是（自定义存储地址） 3.否"
   read -t 15 tempp
   tempp=${tempp:-1}
   if [ $tempp -eq "2" ] ; then
         echo "请指定log存储地址（请确定地址有效！否则请在使用前先mkdir地址）"
		 read path_temp
		 log_path_temp=$path_temp
		 log_para_temp="--log $log_path_temp"
   elif [ $tempp -eq "3" ] ; then
	     log_para_temp=""
   fi
   echo "是否加入开机自启动 (默认为否)"
   echo "1.是 2.否"
   read -t 15 tempp
   tempp=${tempp:-2}
	 if [ $tempp -eq "1" ] ; then
         echo "proxy "http $secure_para_temp -t kcp -p ":$port" --kcp-key $passwd $guard_temp $log_para_temp $bk_temp" " >> /etc/auto_run_proxy.sh
     fi
   echo "请在本地打开服务指令为："
   echo "proxy http -t tcp -p ":8080" -T kcp -P "$ip_addr:$port" --kcp-key $passwd"
   echo "#默认本地端口为8080 "
   run_proxy "http $secure_para_temp -t kcp -p ":$port" --kcp-key $passwd $guard_temp $log_para_temp $bk_temp"

   ;;
   
3) secure_para_temp=$secure_para
   bk_temp=$bk
   guard_temp=$guard
   log_path_temp=$log_path
   log_para_temp="--log $log_path_temp"
   echo "***********请选择代理类型*************"
   echo "1.使用TLS加密（二级代理）2.使用TLS加密（多(>=3)级代理）"
   echo "3.不使用TLS加密（一级代理）4.不使用TLS加密（二级代理）"
   echo "5.不使用TLS加密（多（>=3）级代理）"
   echo "***************************************"
   read temp
   if [ $temp -eq "1" ] ; then
     echo "请输入TLS证书保存路径"
	 read path
	 echo "是否重新生成TLS证书"
	 echo "1.是 2.否"
	 read tempp
	 if [ $tempp -eq "1" ] ; then
         cd $path
		 rm -f proxy.crt proxy.key
         proxy keygen -C proxy
		 echo "是否现在就回传证书 （默认为回传）"
		 echo "1.是   2.否"
		 read -t 15 tempp
		 tempp=${tempp:-1}
		 if [ $tempp -eq "1" ] ; then
		     sz proxy.crt proxy.key
		 fi
     fi
     echo "***************************************"
     echo "     请输入需要使用的服务器端口号      "
     echo "***************************************"
     read port
	 echo "是否使用安全参数 -g your_VPS_IP （默认为使用）"
	 echo "1.是 2.否"
	 read -t 15 tempp
	 tempp=${tempp:-1}
	 if [ $tempp -eq "2" ] ; then
         secure_para_temp=$NULL
     fi
	 echo "是否监控proxy运行 （默认为后台，不监控）"
	 echo "1.否 2.是"
	 read -t 15 tempp
	 tempp=${tempp:-1}
	 if [ $tempp -eq "2" ] ; then
         bk_temp=$NULL
         guard_temp=$NULL
         log_path_temp=$NULL
         log_para_temp=$NULL
		 cd $path
		 echo "请在本地打开服务指令为："
		 echo "proxy socks -t tcp -p ":8080" -T tls -P "$ip_addr:$port" -C proxy.crt -K proxy.key "
		 echo "#默认本地端口为8080 请将证书文件和可执行文件放置在同一目录下"
		 run_proxy "socks $secure_para_temp -t tls -p "":$port"" -C $path/proxy.crt -K $path/proxy.key $guard_temp $log_para_temp $bk_temp"
		 exit 
     fi
	 echo "是否守护执行 （默认为使用）"
	 echo "1.是 2.否"
	 read -t 15 tempp
	 tempp=${tempp:-1}
	 if [ $tempp -eq "2" ] ; then
         guard_temp=$NULL
     fi
     echo "日志功能 （默认为开启 存储地址为$log_path）"
	 echo "1.是(默认地址) 2.是（自定义存储地址） 3.否"
	 read -t 15 tempp
	 tempp=${tempp:-1}
	 if [ $tempp -eq "2" ] ; then
         echo "请指定log存储地址（请确定地址有效！否则请在使用前先mkdir地址）"
		 read path_temp
		 log_path_temp=$path_temp
		 log_para_temp="--log $log_path_temp"
	 elif [ $tempp -eq "3" ] ; then
	     log_para_temp=""
	 fi
	 cd $path
	 echo "请在本地打开服务指令为："
	 echo "proxy socks -t tcp -p ":8080" -T tls -P "$ip_addr:$port" -C proxy.crt -K proxy.key "
	 echo "#默认本地端口为8080 请将证书文件和可执行文件放置在同一目录下"
	 run_proxy "socks $secure_para_temp -t tls -p "":$port"" -C $path/proxy.crt -K $path/proxy.key $guard_temp $log_para_temp $bk_temp"
   elif [ $temp -eq "2" ] ; then
     echo "未完待续"
     #up_ip_addr=""
	 #trans="tls"
	 #up_para=" -T $trans -P "$up_ip_addr" "
     #echo "***********您的服务器是否有上级？***********"
	 #echo "1.有 2.没有"
	 #read tempp
	 #if [ $tempp -eq "1" ] ; then
	    # echo "请输入上级ip:端口 "
	#	 read up_ip_addr
	#	 echo "请选择上级服务器传输方式"
	#	 echo "1.tls 2.tcp 3.kcp 4.socks"
	 #fi 
   elif [ $temp -eq "3" ] ; then
     echo "***************************************"
     echo "     请输入需要使用的服务器端口号      "
     echo "***************************************"
     read port
	 echo "是否使用安全参数 -g your_VPS_IP （默认为使用）"
	 echo "1.是 2.否"
	 read -t 15 tempp
	 tempp=${tempp:-1}
	 if [ $tempp -eq "2" ] ; then
         secure_para_temp=$NULL
     fi
	 echo "是否监控proxy运行 （默认为后台，不监控）"
	 echo "1.否 2.是"
	 read -t 15 tempp
	 tempp=${tempp:-1}
	 if [ $tempp -eq "2" ] ; then
         bk_temp=$NULL
         guard_temp=$NULL
         log_path_temp=$NULL
         log_para_temp=$NULL
		 cd $path
		 echo "请在本地打开服务指令为："
		 echo "proxy socks -p "0.0.0.0:8080" -T tcp -P "$ip_addr:$port""
	     echo "#默认本地端口为8080 "
		 run_proxy "socks $secure_para_temp -t tcp -p "":$port"" $guard_temp $log_para_temp $bk_temp"
		 exit 
     fi
	 echo "是否守护执行 （默认为使用）"
	 echo "1.是 2.否"
	 read -t 15 tempp
	 tempp=${tempp:-1}
	 if [ $tempp -eq "2" ] ; then
         guard_temp=$NULL
     fi
     echo "日志功能 （默认为开启 存储地址为$log_path）"
	 echo "1.是(默认地址) 2.是（自定义存储地址） 3.否"
	 read -t 15 tempp
	 tempp=${tempp:-1}
	 if [ $tempp -eq "2" ] ; then
         echo "请指定log存储地址（请确定地址有效！否则请在使用前先mkdir地址）"
		 read path_temp
		 log_path_temp=$path_temp
		 log_para_temp="--log $log_path_temp"
	 elif [ $tempp -eq "3" ] ; then
	     log_para_temp=""
	 fi
	 cd $path
	 echo "请在本地打开服务指令为："
	 echo "proxy socks -p "0.0.0.0:8080" -T tcp -P "$ip_addr:$port""
	 echo "#默认本地端口为8080 "
	 run_proxy "socks $secure_para_temp -t tcp -p ""0.0.0.0:$port"" $guard_temp $log_para_temp $bk_temp"
   elif [ $temp -eq "4" ] ; then
     echo "***************************************"
     echo "     请输入需要使用的服务器端口号      "
     echo "***************************************"
     read port
	 echo "是否使用安全参数 -g your_VPS_IP （默认为使用）"
	 echo "1.是 2.否"
	 read -t 15 tempp
	 tempp=${tempp:-1}
	 if [ $tempp -eq "2" ] ; then
         secure_para_temp=$NULL
     fi
	 echo "是否监控proxy运行 （默认为后台，不监控）"
	 echo "1.否 2.是"
	 read -t 15 tempp
	 tempp=${tempp:-1}
	 if [ $tempp -eq "2" ] ; then
         bk_temp=$NULL
         guard_temp=$NULL
         log_path_temp=$NULL
         log_para_temp=$NULL
		 cd $path
		 echo "请在本地打开服务指令为："
		 echo "proxy socks -p "0.0.0.0:8080" -T tcp -P "$ip_addr:$port""
	     echo "#默认本地端口为8080 "
		 run_proxy "socks $secure_para_temp -t tcp -p "":$port"" $guard_temp $log_para_temp $bk_temp"
		 exit 
     fi
	 echo "是否守护执行 （默认为使用）"
	 echo "1.是 2.否"
	 read -t 15 tempp
	 tempp=${tempp:-1}
	 if [ $tempp -eq "2" ] ; then
         guard_temp=$NULL
     fi
     echo "日志功能 （默认为开启 存储地址为$log_path）"
	 echo "1.是(默认地址) 2.是（自定义存储地址） 3.否"
	 read -t 15 tempp
	 tempp=${tempp:-1}
	 if [ $tempp -eq "2" ] ; then
         echo "请指定log存储地址（请确定地址有效！否则请在使用前先mkdir地址）"
		 read path_temp
		 log_path_temp=$path_temp
		 log_para_temp="--log $log_path_temp"
	 elif [ $tempp -eq "3" ] ; then
	     log_para_temp=""
	 fi
	 cd $path
	 echo "请在本地打开服务指令为："
	 echo "proxy socks -p "0.0.0.0:8080" -T tcp -P "$ip_addr:$port""
	 echo "#默认本地端口为8080 "
	 run_proxy "socks $secure_para_temp -t tcp -p ""0.0.0.0:$port"" $guard_temp $log_para_temp $bk_temp"
   elif [ $temp -eq "5" ] ; then
     echo "未完待续"
   fi
   

   ;;
   
4) echo "未完待续"

   ;;
   
5) echo "未完待续"

   ;;
   
6) echo "正在删除所有开机任务"
   rm -f /etc/auto_run_proxy.sh
   touch /etc/auto_run_proxy.sh
   chmod +x /etc/auto_run_proxy.sh
   echo "删除proxy开机任务成功"
   
   ;;
   
   
7) echo "正在关闭所有proxy后台进程"
   pkill proxy
   echo "proxy进程清理完毕"
   
   ;;
   
   
esac








