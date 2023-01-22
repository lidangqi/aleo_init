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
    PROC_NAME=ironfish
    ProcNumber=$(ps -ef | grep -w $PROC_NAME | grep -v grep | wc -l)
    if [ "$ProcNumber" -le 0 ];then
        echo "ironfish is not run"
        nohup ironfish start >> /root/ironfish_node.log 2>&1 &   
    else
        echo "ironfish already running."
    fi
}

run_wallet_create() {
    ironfish wallet:create
}

run_testnet() {
    ironfish testnet
}

run_wallet_mint() {
    #mycoin=$(ironfish wallet:address | awk '{print $2}' | sed -e 's/,//g')
    ironfish wallet:mint

run_wallet_burn() {
    #assetId=$(ironfish wallet:balances | sed -n "4,1p" | awk '{print $2}')
    ironfish wallet:burn
}

run_wallet_send() {
    ironfish wallet:send --to dfc2679369551e64e3950e06a88e68466e813c63b100283520045925adbe59ca
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

start_menu() {
    
    clear

    while true
    do
    green " ========================================== "
    green " ironfish npm一键安装管理脚本"
    green "     Allen_Li   v1.0.0"
    green " ========================================== "
    echo
    red " ———————————————— 安装向导 ———————————————— "
    yellow " 1. 安装ironfish"
    red    " (功能2 输入用户涂鸦)"
    yellow " 2. 创建钱包"
    red    " (功能3 输入用户涂鸦或测试网用户的url，如https://testnet.ironfish.network/users/1080)"
    yellow " 3. 绑定涂鸦号"
    red    " (功能4 需先执行1/2 创建钱包,绑定涂鸦号后,运行)"
    yellow " 4. 运行/重启节点"
    red    " (功能5/6/7/8/9必须同步完节点后使用)"
    yellow " 5. 任务一:铸币"
    yellow " 6. 任务二:燃烧铸币"
    yellow " 7. 任务三:发送铸币"
    yellow " 8. 查看钱包余额"
    yellow " 9. 查看交易记录"
    yellow " 10. 水龙头"
    yellow " 11. 查看节点日志"
    yellow " 12. 查看节点状态"
    yellow " 0. 退出 管理脚本"
    green " ========================================== "
    read -rp "Please enter a number:  " num
    case "$num" in
    1)
        install_ironfish_env
        ;;
    2)
        run_wallet_create
        ;;
    3)
        run_testnet
        ;;
    4)
        run_ironfish
        ;;
    5)
        run_wallet_mint
        ;;
    6)
        run_wallet_burn
        ;;
    7)
        run_wallet_send
        ;;
    8)
        run_wallet_balances
        ;;
    9)
        run_wallet_transactions
        ;;
    10)
        run_faucet
        ;;
    11)
        run_read_log
        ;;
    12)
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
