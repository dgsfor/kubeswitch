#!/bin/bash


# -------------------------------
# 脚本：k8s集群切换
# 支持集群：本地集群、普通k8s集群、谷歌gke集群
# author： dgsfor@gmail.com
# -------------------------------

# -------------------------------
# 1.装一下jq插件
#
# -------------------------------

DIRNAME=$0
if [ "${DIRNAME:0:1}" = "/" ];then
    CURDIR=`dirname $DIRNAME`
else
    CURDIR="`pwd`"/"`dirname $DIRNAME`"
fi

PrintCluster(){
    echo "\033[32m 集群列表如下： \033[0m"
    cat $CURDIR/kubeconfig.json | jq -rf  $CURDIR/jsonformat | column -t
}
PrintCluster


SwitchCluster(){
    num=`expr $1 - 1`
    clusterName=`cat $CURDIR/kubeconfig.json | jq '.['${num}'].clusterName'` 
    clusterType=`cat $CURDIR/kubeconfig.json | jq '.['${num}'].clusterType'` 
    kubeconfig=`cat $CURDIR/kubeconfig.json | jq '.['${num}'].kubeconfig'` 
    serviceaccount=`cat $CURDIR/kubeconfig.json | jq '.['${num}'].serviceaccount'` 
    export GOOGLE_APPLICATION_CREDENTIALS=`echo $serviceaccount | sed 's/\"//g'`
    export KUBECONFIG=`echo $kubeconfig | sed 's/\"//g'`
    echo "\033[1;36m 成功切换到集群：\033[0m [\033[33m $clusterName \033[0m]" 
}

# 集群个数
itemcount=`cat $CURDIR/kubeconfig.json | jq length`

while True
do
    echo "\033[1;36m 请选择一个集群进行切换：\033[0m"
    read input
    expr $input + 1 &>/dev/null
    if [ $? != 0 ];then
        echo "\033[33m [[请输入正确的集群编号!]] \033[0m"
    else
        if [ $input -gt $itemcount -o $input -le 0 ];then
            echo "\033[33m [[请输入正确的集群编号!]] \033[0m" 
        else
            SwitchCluster $input
            break
        fi
    fi
done