#!/usr/bin/env bash
set -u
KWS='doh\.|dns-query|205\.164|proxy|PAC|pac_|tunnel|vpn|sing-box|vless|vmess|trojan|hysteria|shadowsocks|https_proxy|HTTPS_PROXY|scholar\.|startclient|config\.ini|dns'
echo "########## FILES (selected) ##########"
grep -iE '\.(ini|json|conf|pac|cfg|xml|yaml|yml|sh|txt|desktop)$|config|proxy|dns|cert' files.txt | head -200
echo "########## SMALL TEXT FILES CONTENT ##########"
find out -type f \( -iname '*.ini' -o -iname '*.json' -o -iname '*.conf' -o -iname '*.cfg' -o -iname '*.xml' -o -iname '*.desktop' -o -iname '*.sh' -o -iname '*.txt' -o -iname '*.pac' \) -size -200k 2>/dev/null | head -100 | while read -r f; do echo "----- $f ($(stat -c%s "$f"))"; head -c 20000 "$f"; echo; done
echo "########## CONTROL SCRIPTS ##########"
for f in ctl/postinst ctl/postrm ctl/preinst ctl/control ctl/conffiles; do [ -f "$f" ] && { echo "--- $f"; cat "$f"; echo; }; done
echo "########## EXEC/DESKTOP LINES ##########"
grep -rhE 'Exec=|startclient|--proxy|--host-resolver|chromium' out 2>/dev/null | head -100
echo "########## STRINGS SCAN: binaries < 60MB ##########"
find out -type f -size -60M 2>/dev/null | while read -r f; do
  case "$f" in *.pak|*.dat|*.bin|*.png|*.jpg|*.ico|*.ttf|*.woff*) continue;; esac
  t=$(file -b "$f" 2>/dev/null)
  case "$t" in *ELF*|*executable*) ;; *) continue;; esac
  n=$(strings -n 6 "$f" 2>/dev/null | grep -iE "$KWS" | sort -u | head -60)
  if [ -n "$n" ]; then echo "===== $f ($(stat -c%s "$f")) :: $t"; echo "$n"; fi
done
echo "########## STRINGS SCAN: resources ##########"
find out -type f -size -8M 2>/dev/null | grep -viE '\.(png|jpg|jpeg|ico|gif|ttf|otf|woff2?|pak|dat|bin|so)$' | head -600 | while read -r f; do
  n=$(strings -n 8 "$f" 2>/dev/null | grep -iE 'doh\.|dns-query|205\.164|scholar\.(work|edu)|proxy|pac|tunnel|sing-box|vless|vmess|trojan' | sort -u | head -20)
  if [ -n "$n" ]; then echo "===== $f"; echo "$n"; fi
done
echo "########## DEFAULT CONFIG LOCATIONS ##########"
find out -type f 2>/dev/null | grep -Ei 'config|\.ini|\.pac|\.json|cert|proxy' | head -100
echo "########## DONE ##########"
