#!/bin/bash

source "$HOME/.cargo/env"

echo "安装jq"
sudo apt install jq -y

wallet=aleo10wmckukaygmphd447tc6aqdq6rfkj9x5ghcg7gxe5wfrza84dgyqy9486c
workername=$(hostname -I | awk -F . '{print $4}' | awk '{print $1}')

echo "判断是否安装锄头"
VERSION=$(curl -k -sL https://api.github.com/repos/damomine/aleominer/releases | jq -r ".[0].tag_name")

echo "VERSION=$VERSION"

if [ -f /root/damominer_$VERSION/damominer ]
    then
        echo "已经安装过锄头"
        cd /root/damominer_$VERSION
    else
        echo "没有安装锄头,开始下载安装"
        echo "修复libssl1.修复"
        echo "deb http://security.ubuntu.com/ubuntu focal-security main" | sudo tee /etc/apt/sources.list.d/focal-security.list
        sudo apt-get update -y 
        sudo apt-get install libssl1.1  -y
        mkdir -p /root/damominer_$VERSION
        if [ -f /root/damominer_linux_$VERSION.tar ]
            then 
               tar -xvf damominer_linux_$VERSION.tar -C /root/damominer_$VERSION
               chmod a+x /root/damominer_$VERSION/damominer
               cd /root/damominer_$VERSION
               rm -rf /root/damominer_$VERSION/run_gpu.sh
            else
               if [ ! -n $VERSION ]
                  then
                     wget --no-check-certificate https://ghproxy.com/https://github.com/damomine/aleominer/releases/download/v2.2.0/damominer_linux_v2.2.0.tar
                  else
                     wget --no-check-certificate https://ghproxy.com/https://github.com/damomine/aleominer/releases/download/$VERSION/damominer_linux_$VERSION.tar
               fi
               tar -xvf damominer_linux_$VERSION.tar -C /root/damominer_$VERSION
               chmod a+x /root/damominer_$VERSION/damominer
               cd /root/damominer_$VERSION
               rm -rf /root/damominer_$VERSION/run_gpu.sh
        fi

        echo "判断是否安装rust"
        if [ ! "$(command -v rustc)" ]
            then
                echo "rust没有安装,开始安装rust"
                    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh  -s -- -y
                    source "$HOME/.cargo/env"
                    echo "rust安装成功!"
            else
                    version=`rustc -V`
                    echo "rust已安装! ${version}"
        fi

        

        #read -p "请输入您的钱包地址 > " wallet
        
        #sleep 8
        
        #read -p "请输入机器编号 > " workername
        
        #sleep 8

fi

echo "创建damominer启动脚本"
cat > /root/damominer_$VERSION/run_gpu.sh << EOF
#!/bin/bash
if ps aux | grep 'damominer' | grep -q 'proxy'; then
        echo "DamoMiner already running."
        exit 1
else
    nohup /root/damominer_$VERSION/damominer --address $wallet --proxy aleovip1.damominer.hk:9090 --worker sz$workername >> /root/damominer_$VERSION/aleo.log 2>&1 &
fi
EOF

echo "创建damominer停止脚本"
cat > /root/damominer_$VERSION/stop_gpu.sh << EOF
#!/bin/bash

killall damominer
EOF

rm -rf /etc/systemd/system/damominer.service
chmod a+x /root/damominer_$VERSION/damominer
chmod a+x /root/damominer_$VERSION/run_gpu.sh
chmod a+x /root/damominer_$VERSION/stop_gpu.sh

echo "创建damominer开机启动service"
cat > /etc/systemd/system/damominer.service << EOF
[Unit]
Description=damominer
Documentation=https://github.com/lidangqi/hz/new/master
After=network.target

[Service]
Type=forking
User=root
Group=root
WorkingDirectory = /root/damominer_$VERSION
ExecStart = /bin/sh /root/damominer_$VERSION/run_gpu.sh
ExecStop = /bin/sh /root/damominer_$VERSION/stop_gpu.sh
[Install]
WantedBy=multi-user.target
EOF



killall damominer
sed -i "s/aleo3.d/aleovip1.d/g" /root/damominer_$VERSION/run_gpu.sh

systemctl daemon-reload 
sleep 2
systemctl enable damominer
sleep 2
/bin/sh /root/damominer_$VERSION/run_gpu.sh

tail -f /root/damominer_$VERSION/aleo.log
