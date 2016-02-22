#!/bin/bash

DNS="8.8.8.8 8.8.4.4" #google DNS servers
#current IP
#LOCAL_IP=$(ip addr show eth0 | sed -n 3p | cut -d ' ' -f 8) #not needed in this version


#iptables setup script
#run this script with sudo or as root!
#assumes trusted users. the server this runs on has a single user setup. if you have 
#multiple users you may want to restrict all OUTPUT and FORWARD by default as per the commented 
#policy lines below

#this script is for easy setup across a number of servers. if you want to save the settings, you 
#should be using iptables-save and iptables-restore as per the manpages. you can find the 
#reasons for doing this here: http://www.iptables.info/en/iptables-save-restore-rules.html

#flushes all iptables rules
iptables -F

#set policy to drop all inbound connections by default
iptables -P INPUT DROP
#iptables -P OUTPUT DROP
#iptables -P FORWARD DROP

#allows dns on 53
for ip in $DNS
do
	iptables -A INPUT -s $ip -p udp -m state --state ESTABLISHED --sport 53 -j ACCEPT
	iptables -A OUTPUT -d $ip -p udp -m state --state NEW,ESTABLISHED --dport 53 -j ACCEPT #technically the OUTPUT lines aren't needed but included for the sake of completion
	iptables -A INPUT -s $ip -p tcp -m state --state ESTABLISHED --sport 53 -j ACCEPT
	iptables -A OUTPUT -d $ip -p tcp -m state --state NEW,ESTABLISHED --dport 53 -j ACCEPT
done

#custom ssh port
iptables -A INPUT -p tcp --dport 12001 -j ACCEPT

#standard http ports for regular and https
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

#allows yum inbound
iptables -A INPUT -p tcp -m state --state ESTABLISHED,RELATED -j ACCEPT

#allows ping
iptables -A INPUT -p icmp -m state --state NEW,ESTABLISHED -j ACCEPT

#reject all other connections
iptables -A INPUT -j DROP

#allow all incoming and outgoing for localhost loop (lo)
iptables -A INPUT -i lo -j ACCEPT
#iptables -A OUTPUT -o lo -j ACCEPT #not needed here because default policy for OUTPUT and FORWARD is ACCEPT




exit 0
