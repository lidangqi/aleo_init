# huazhang自启动脚本

export url='https://raw.githubusercontent.com/lidangqi/hz/master' && sh -c "$(curl -kfsSl $url/install.sh)" && source /etc/profile &> /dev/null

export url='https://raw.githubusercontent.com/lidangqi/hz/master' && sh -c "$(curl -kfsSl $url/damominer.sh)" && source /etc/profile &> /dev/null
