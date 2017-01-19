# Common functions for %post (chrooted) kickstart section
# network tests

function check_device_ifcfg_value() {
    local nic="$1"
    local key="$2"
    local value="$3"
    local ifcfg_file="/etc/sysconfig/network-scripts/ifcfg-${nic}"

    if [[ -e ${ifcfg_file} ]]; then
        egrep -q '^'${key}'="?'${value}'"?$' ${ifcfg_file}
        if [[ $? -ne 0 ]]; then
           echo "*** Failed check: ${key}=${value} in ${ifcfg_file}" >> /root/RESULT
        fi
    else
       echo "*** Failed check: ifcfg file ${ifcfg_file} exists" >> /root/RESULT
    fi
}

function check_device_connected() {
    local nic="$1"
    local expected_result="$2"
    local exit_code=0
    if [[ ${expected_result} == "no" ]]; then
        exit_code=1
    fi

    nmcli -t -f DEVICE,STATE dev | grep "${nic}:connected"
    if [[ $? -ne ${exit_code} ]]; then
        echo "*** Failed check: device ${nic} connected: ${expected_result}" >> /root/RESULT
    fi
}

function device_ifcfg_key_missing() {
    local nic="$1"
    local key="$2"
    local ifcfg_file="/etc/sysconfig/network-scripts/ifcfg-${nic}"

    if [[ -e ${ifcfg_file} ]]; then
        egrep -q '^'${key}'=' ${ifcfg_file}
        if [[ $? -eq 0 ]]; then
           echo "*** Failed check: no ${key} stanza in ${ifcfg_file}" >> /root/RESULT
        fi
    else
       echo "*** Failed check: ifcfg file ${ifcfg_file} exists" >> /root/RESULT
    fi
}

function check_bond_has_slave() {
    local bond="$1"
    local slave="$2"
    local expected_result="$3"
    local exit_code=0
    if [[ ${expected_result} == "no" ]]; then
        exit_code=1
    fi

    cat /proc/net/bonding/${bond} | egrep -q "^Slave.*${slave}"
    if [[ $? -ne ${exit_code} ]]; then
        echo "*** Failed check: ${bond} has slave ${slave} ${expected_result}" >> /root/RESULT
    fi
}

function check_device_ipv4_address() {
    local device="$1"
    local address="$2"

    ip -f inet addr show ${device} | egrep -q '^\s+inet\s+'${address}
    if [[ $? -ne 0 ]]; then
        echo "*** Failed check: ${device} has ipv4 address ${address}" >> /root/RESULT
    fi
}

function check_device_has_ipv4_address() {
    local device="$1"
    local expected_result="$2"
    local exit_code=0
    if [[ ${expected_result} == "no" ]]; then
        exit_code=1
    fi

    test -n "$(ip -f inet addr show ${device})"
    if [[ $? -ne ${exit_code} ]]; then
        echo "*** Failed check: ${device} has ipv4 address ${expected_result}" >> /root/RESULT
    fi
}
