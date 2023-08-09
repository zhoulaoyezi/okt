#!/bin/bash

#Xray版本
if [[ -z "${VER}" ]]; then
  VER="latest"
fi
echo ${VER}

if [[ -z "${Vless_Path}" ]]; then
  Vless_Path="/fgh76u4wrgjyu"
fi
echo ${Vless_Path}

if [[ -z "${Vless_UUID}" ]]; then
  Vless_UUID="99af137f-3a11-4df6-9216-c8a37100b991"
fi
echo ${Vless_UUID}

if [[ -z "${Vmess_Path}" ]]; then
  Vmess_Path="/fdbjui75u56ehtd"
fi
echo ${Vmess_Path}

if [[ -z "${Vmess_UUID}" ]]; then
  Vmess_UUID="99af137f-3a11-4df6-9216-c8a37100b991"
fi
echo ${Vmess_UUID}

if [[ -z "${Share_Path}" ]]; then
  Share_Path="/v2link"
fi
echo ${Share_Path}

if [ "$VER" = "latest" ]; then
  VER=`wget -qO- "https://api.github.com/repos/XTLS/Xray-core/releases/latest" | sed -n -r -e 's/.*"tag_name".+?"([vV0-9\.]+?)".*/\1/p'`
  [[ -z "${VER}" ]] && VER="v1.5.4"
else
  VER="v$VER"
fi

mkdir /xraybin
cd /xraybin
RAY_URL="https://github.com/XTLS/Xray-core/releases/download/${VER}/Xray-linux-64.zip"
echo ${RAY_URL}
wget --no-check-certificate ${RAY_URL}
unzip Xray-linux-64.zip
rm -f Xray-linux-64.zip
chmod +x ./xray
ls -al

# cd /wwwroot
# tar xvf wwwroot.tar.gz
# rm -rf wwwroot.tar.gz

# Install Html
mkdir /wwwroot
wget -qO /tmp/html.zip ${Site} 
unzip -qo /tmp/html.zip -d /wwwroot 
rm -rf /tmp/html.zip

sed -e "/^#/d"\
    -e "s/\${Vless_UUID}/${Vless_UUID}/g"\
    -e "s|\${Vless_Path}|${Vless_Path}|g"\
    -e "s/\${Vmess_UUID}/${Vmess_UUID}/g"\
    -e "s|\${Vmess_Path}|${Vmess_Path}|g"\
    /conf/Xray.template.json >  /xraybin/config.json
echo /xraybin/config.json
cat /xraybin/config.json


sed -e "/^#/d"\
    -e "s/\${PORT}/${PORT}/g"\
    -e "s|\${Vless_Path}|${Vless_Path}|g"\
    -e "s|\${Vmess_Path}|${Vmess_Path}|g"\
    -e "s|\${Share_Path}|${Share_Path}|g"\
    -e "$s"\
    /conf/nginx.template.conf > /etc/nginx/conf.d/ray.conf
echo /etc/nginx/conf.d/ray.conf
cat /etc/nginx/conf.d/ray.conf

[ ! -d /wwwroot/${Share_Path} ] && mkdir -p /wwwroot/${Share_Path}
sed -e "/^#/d"\
    -e "s|\${_Vless_Path}|${Vless_Path}|g"\
    -e "s|\${_Vmess_Path}|${Vmess_Path}|g"\
    -e "s/\${_Vless_UUID}/${Vless_UUID}/g"\
    -e "s/\${_Vmess_UUID}/${Vmess_UUID}/g"\
    -e "$s"\
    /conf/share.html > /wwwroot/${Share_Path}/index.html
echo /wwwroot/${Share_Path}/index.html
cat /wwwroot/${Share_Path}/index.html

cd /xraybin
./xray run -c ./config.json &
rm -rf /etc/nginx/sites-enabled/default
nginx -g 'daemon off;'
