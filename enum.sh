#!/bin/bash

url=$1


if [ ! -d "$url" ];then
	mkdir $url
fi

if [ ! -d "$url/domains" ];then
	mkdir $url/domains
fi

if [ ! -d "$url/wayback" ];then
	mkdir $url/wayback
fi

if [ ! -d "$url/wayback/ext" ];then
	mkdir $url/wayback/ext
fi

if [ ! -d "$url/nmap" ];then
	mkdir $url/nmap
fi


echo "[+] Getting sub-domains with assetfinder..."
assetfinder --subs-only $url >> $url/domains/assetfinder_lists.txt 
cat $url/domains/assetfinder_lists.txt | grep $1 >> $url/domains/asset_finals.txt
rm $url/domains/assetfinder_lists.txt

echo "[+] Getting subdomains with AMASS..."
amass db -names -d $url >> $url/domains/amass_lists.txt
cat $url/domains/amass_lists.txt | grep $1 

echo "[+] Probing for https connections ...."
cat $url/domains/asset_finals.txt | sort -u | httprobe -s -p https:443 | tr -d ':443' >>$url/domains/https_probe_asset.txt

##cat $url/domains/https_probe_asset.txt 

echo "[+] Probing for http connections ...."
cat $url/domains/asset_finals.txt | sort -u | httprobe -s -p http:80 | tr -d ':80'>>$url/domains/http_probe_asset.txt

##cat $url/domains/http_probe_asset.txt 

echo "[+] Probing for https connections for amass ...."
cat $url/domains/amass_lists.txt | sort -u | httprobe -s -p https:443 | tr -d ':443'>>$url/domains/https_probe_amass.txt

##cat $url/domains/https_probe_amass.txt 

echo "[+] Probing for http connections for amass ...."
cat $url/domains/amass_lists.txt | sort -u | httprobe -s -p http:80 | tr -d ':80'>>$url/domains/http_probe_amass.txt

##cat $url/domains/http_probe_amass.txt 
echo "[+] Finding https wayback documents ...."
cat $url/domains/https_probe_asset.txt | waybackurls >> $url/wayback/https_wayback.txt
sort -u $url/wayback/https_wayback.txt

echo "[+] Finding http wayback documents ...."
cat $url/domains/http_probe_asset.txt | waybackurls >> $url/wayback/http_wayback.txt
sort -u $url/wayback/http_wayback.txt

echo "[+] Running nmap scan"
cat $url/domains/http_probe_asset.txt | tr -d 'http//' >> $url/domains/http_strip.txt 
nmap -iL $url/domains/http_strip.txt -T4 -oA $url/nmap/http_scans.txt
rm $url/domains/http_strip.txt
cat $url/domains/https_probe_asset.txt| tr -d 'https//' >> $url/domains/https_strip.txt 
nmap -iL $url/domains/https_strip.txt -T4 -oA $url/nmap/https_scans.txt
rm $url/domains/https_strip.txt

