#!/bin/bash

DNS="8.8.8.8 8.8.4.4"
#current IP
LOCAL_IP=$(ip addr show eth0 | sed -n 3p | cut -d ' ' -f 8)


#iptables setup script
#run this script with sudo or as root!

#flushes all iptables rules
iptables -F

#set policy to drop all connections
iptables -P INPUT DROP

#allows dns on 53
for ip in $DNS
do
	iptables -A INPUT -s $ip -p udp -m state --state ESTABLISHED --sport 53 -j ACCEPT
	iptables -A OUTPUT -d $ip -p udp -m state --state NEW,ESTABLISHED --dport 53 -j ACCEPT
	iptables -A INPUT -s $ip -p tcp -m state --state ESTABLISHED --sport 53 -j ACCEPT
	iptables -A OUTPUT -d $ip -p tcp -m state --state NEW,ESTABLISHED --dport 53 -j ACCEPT
done

#custom ssh port
iptables -A INPUT -p tcp --dport 12001 -j ACCEPT

#standard http ports for regular and https
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

#github
iptables -A INPUT -p tcp --dport 873 -m state --state NEW,ESTABLISHED -j ACCEPT

#allows yum inbound
iptables -A INPUT -p tcp -m state --state ESTABLISHED,RELATED -j ACCEPT

#allows ping
iptables -A INPUT -p icmp -m state --state NEW,ESTABLISHED -j ACCEPT

#reject all other connections
iptables -A INPUT -j DROP

#allow all incoming and outgoing for localhost loop (lo)
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT




exit 0
