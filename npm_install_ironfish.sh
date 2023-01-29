#!/bin/bash

# 字体颜色配置
Yellow="\033[33m"
Green="\033[32m"
Red="\033[31m"
Blue="\033[36m"
Font="\033[0m"

# 提示
INFO="[${Green}Info${Font}]"
ERROR="[${Red}Error${Font}]"
TIP="[${Green}Tip${Font}]"

yellow() {
    echo -e "${Yellow} $1 ${Font}"
}

green() {
    echo -e "${Green} $1 ${Font}"
}

red() {
    echo -e "${Red} $1 ${Font}"
}

blue() {
    echo -e "${Blue} $1 ${Font}"
}

check_root() {
    [[ $EUID != 0 ]] && {
        if [ "$LANGUAGE" == "cn" ]; then
            echo -e "${ERROR} 当前非 root 账号, 无法继续操作. 请更换 root 账号或使用 ${Blue}sudo su${Font} 命令获取临时 root 权限 (执行后可能会提示输入当前账号的密码)."
        else
            echo -e "${ERROR} The current non-root account cannot continue to operate. Please change the root account or use the ${Blue}sudo su${Font} command to obtain temporary root privileges (after execution, you may be prompted to enter the password of the current account) "
        fi
    } && exit 1
}

install_ironfish_env() {
    apt update -y
    apt install tmux -y
    apt-get install -y build-essential g++ make
    echo "安装nodejs"
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs

    echo "安装ironfish"
    npm config set registry https://registry.npm.taobao.org
    npm install -g npm
    npm install express
    npm init -y
    npm install
    npm update
    npm install -g ironfish
}

run_ironfish() {
    line=$(cat /root/.ironfish/hosts.json | wc -l)
    sleep 2
    killall node
    sleep 2
    if [ "$line" -lt 5 ];then
       wget --no-check-certificate -O /root/.ironfish/hosts.json http://aleo.lidangqi.com/hosts.json
    fi
    PROC_NAME=ironfish
    ProcNumber=$(ps -ef | grep -w $PROC_NAME | grep -v grep | wc -l)
    if [ "$ProcNumber" -le 0 ];then
    nohup ironfish start >> /root/ironfish_node.log 2>&1 &   
    echo "ironfish已放后台运行"
    else
        echo "ironfish已运行"
    fi
}

run_wallet_create() {
    ironfish wallet:create 
}

run_testnet() {
    ironfish testnet
}

run_wallet_mint() {
    mycoin=$(ironfish wallet:address | awk '{print $2}' | sed -e 's/,//g')
    ironfish wallet:mint --metadata="see more here" --name=$mycoin --amount=10000 --fee=0.00000001 --confirm
}

run_wallet_burn() {
    assetId=$(ironfish wallet:balances |grep allen_li1 |awk 'NR==2 {print $2}')
    ironfish wallet:burn --assetId=$assetId --amount=100 --fee=0.00000001 --confirm
}

run_wallet_send() {
    assetId=$(ironfish wallet:balances |grep allen_li1 |awk 'NR==2 {print $2}')
    ironfish wallet:send --to dfc2679369551e64e3950e06a88e68466e813c63b100283520045925adbe59ca --assetId=$assetId --amount=100 --fee=0.00000001 --confirm
}

run_faucet() {
    ironfish faucet
}

run_wallet_balances() {
    ironfish wallet:balances
    ironfish wallet:notes
}

run_wallet_transactions() {
    ironfish wallet:transactions
}

run_read_log() {
    tail -n 10 /root/ironfish_node.log
}

run_status() {
    ironfish status
}

disable_ipv6() {
    echo "net.ipv6.conf.all.disable_ipv6 = 1
    net.ipv6.conf.default.disable_ipv6 = 1
    net.ipv6.conf.lo.disable_ipv6 = 1" > /etc/sysctl.conf
    sysctl -p
}

run_chain_download() {
    ironfish chain:download
}

run_ironfish_update() {
    killall node
    sleep 2
    npm install -g ironfish
    sleep 2
    PROC_NAME=ironfish
    ProcNumber=$(ps -ef | grep -w $PROC_NAME | grep -v grep | wc -l)
    if [ "$ProcNumber" -le 0 ];then
    nohup ironfish start --upgrade >> /root/ironfish_node.log 2>&1 &
    echo "ironfish已放后台运行"
    else
        echo "ironfish已运行"
    fi
}

start_menu() {
    
    clear

    while true
    do
    green " ========================================== "
    green " ironfish npm一键安装管理脚本"
    green "     Allen_Li   v1.0.2 2023-01-29"
    green "     铸币-燃烧-发送直接执行,无需输入"
    green " ========================================== "
    echo
    red " ———————————————— 安装向导 ———————————————— "
    green  " 1. 更新ironfish"
    yellow " 2. 安装ironfish"
    red    " (功能3 输入用户涂鸦)"
    yellow " 3. 创建钱包"
    red    " (功能4 输入用户涂鸦或测试网用户的url，如https://testnet.ironfish.network/users/1080)"
    yellow " 4. 绑定涂鸦号"
    yellow " 5. 区块快照下载"
    red    " (功能6 需先执行3/4/5 创建钱包,绑定涂鸦号后,运行)"
    yellow " 6. 运行/重启节点"
    red    " (功能7必须同步完节点后使用)"
    yellow " 7. 任务一:铸币"
    red    " (功能8/9需铸币到账后才能操作)"
    yellow " 8. 任务二:燃烧铸币"
    yellow " 9. 任务三:发送铸币"
    yellow " 10. 查看钱包余额"
    yellow " 11. 查看交易记录"
    yellow " 12. 水龙头"
    yellow " 13. 查看节点日志"
    yellow " 14. 查看节点状态"
    yellow " 0. 退出 管理脚本"
    green " ========================================== "
    read -rp "Please enter a number:  " num
    case "$num" in
    1)
        run_ironfish_update
        ;;
    2)
        install_ironfish_env
        ;;
    3)
        run_wallet_create
        ;;
    4)
        run_testnet
        ;;
    5)
        run_chain_download
        ;;    
    6)
        run_ironfish
        ;;
    7)
        run_wallet_mint
        ;;
    8)
        run_wallet_burn
        ;;
    9)
        run_wallet_send
        ;;
    10)
        run_wallet_balances
        ;;
    11)
        run_wallet_transactions
        ;;
    12)
        run_faucet
        ;;
    13)
        run_read_log
        ;;
    14)
        run_status
        ;;
    0)
        exit 1
        ;;
    *)
        echo
        echo -e " ${Error} 请输入正确的数字"
        ;;
    esac

    done
}
check_ubuntu
start_menu
