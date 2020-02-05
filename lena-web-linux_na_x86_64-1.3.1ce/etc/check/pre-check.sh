#!/bin/sh

### Name    : pre_check.sh @ JSTK
### Author  : jinschoi
### Version : 0.928
### Date    : 2016-04-10

_check_was_user_name() {
  echo -n "  Enter WAS username : "
  read was_user_name
  printf "%s %s"  "$check_username_str" "${line_str1:${#check_username_str}}"
  username=`grep "^$was_user_name:" /etc/passwd`
  if [ "$username" == null -o "$username" == "" ]; then
    echo " [Fail]    (Add user for WAS Server !)"
  else
    echo " [Success] ($username)"
  fi
}
_check_was_prerequisite() {
  echo "$check_prerequisite_str"
  for rpm in wget gcc gcc-c++ make openssl-devel apr-util-devel
  do
    printf "    %s %s"  "$rpm" "${line_str2:${#rpm}}"
    rpm -qa | grep "^$rpm-" > /dev/null
    if [ $? -eq 0 ]; then
      echo " [Success]"
    else
      echo " [Fail]    (Install [$rpm] package !)"
    fi
  done
}
_check_web_user_name() {
  echo -n "  Enter WEB username : "
  read web_user_name
  printf "%s %s"  "$check_username_str" "${line_str1:${#check_username_str}}"
  username=`grep "^$web_user_name:" /etc/passwd`
  if [ "$username" == null -o "$username" == "" ]; then
    echo " [Fail]    (Add user for WEB Server !)"
  else
    echo " [Success] ($username)"
  fi
}
_check_web_prerequisite() {
  echo "$check_prerequisite_str"
  for rpm in wget gcc gcc-c++ make openssl-devel apr-util-devel flex libtool automake 
  do
    printf "    %s %s"  "$rpm" "${line_str2:${#rpm}}"
    rpm -qa | grep "^$rpm-" > /dev/null
    if [ $? -eq 0 ]; then
      echo " [Success]"
    else
      echo " [Fail]    (Install [$rpm] package !)"
    fi
  done
}
_check_was_dir() {
  printf "%s %s"  "$check_was_dir_str" "${line_str1:${#check_was_dir_str}}"
  if [ -d "$was_dir" ]; then
    echo " [Success] (`ls -ld $was_dir`)"
  else
    echo " [Fail]    (mkdir [$was_dir] directory and chown directory to OS WAS username ($was_user_name) !)"
  fi
}
_check_web_dir() {
  printf "%s %s"  "$check_web_dir_str" "${line_str1:${#check_web_dir_str}}"
  if [ -d "$web_dir" ]; then
    echo " [Success] (`ls -ld $web_dir`)"
  else
    echo " [Fail]    (mkdir [$web_dir] directory and chown directory to OS WEB username ($web_user_name) !)"
  fi
}

clear

check_username_str="  Check username"
check_etc_host_str="  Check /etc/hosts"
check_prerequisite_str="  Check prerequisite package"
check_os_info_str="  Check OS Info"
check_cpu_count_str="  Check CPU Count"
check_mem_total_str="  Check Memory Total"
check_java6_str="  Check Java 6 file"
check_java7_str="  Check Java 7 file"
line_str1='............................'
line_str2='........................'

check_was_dir_str="  Check LENA WAS directory"
check_web_dir_str="  Check LENA Web directory"
was_dir="/engn001/lena"
web_dir="/engn001/lenaw"

echo ""
echo "  ================================================================="
echo "  Select the type of this host [`uname -n`]"
echo "  ================================================================="
echo ""
echo "    1. WAS (LENA Application Server)"
echo "    2. WEB (LENA Web  Server)"
echo "    3. WAS/WEB (LENA Web/Application Server)"
echo ""
echo -n "  [ 1 / 2 / 3 ] : "
read host_type

echo ""
if [ $host_type -eq 1 ]; then
  _check_was_user_name
  _check_was_prerequisite
  _check_was_dir
elif [ $host_type -eq 2 ]; then
  _check_web_user_name
  _check_web_prerequisite
  _check_web_dir
elif [ $host_type -eq 3 ]; then
  _check_was_user_name
  _check_was_prerequisite
  _check_web_user_name
  _check_web_prerequisite
  _check_was_dir
  _check_web_dir
else
  echo ""
  echo "  Error. Unknown host."
  echo ""
  exit 1
fi

printf "%s %s"  "$check_etc_host_str" "${line_str1:${#check_etc_host_str}}"
check_etc_hosts=`grep "\`uname -n\`" /etc/hosts | grep -v "^#" | grep -v '127.0.0.1' | grep -v 'localhost'`
if [ "$check_etc_hosts" == null -o "$check_etc_hosts" == "" ]; then
  echo " [Fail]    (Put your real ip address and hostname into /etc/hosts !)"
else
  echo " [Success] ($check_etc_hosts)"
fi

printf "%s %s %s\n" "$check_os_info_str" "${line_str1:${#check_os_info_str}}" "`uname -sr`"
cpu_count=`grep processor /proc/cpuinfo | wc -l`
printf "%s %s %s\n" "$check_cpu_count_str" "${line_str1:${#check_cpu_count_str}}" "$cpu_count"
mem_total=`grep MemTotal /proc/meminfo | cut -d':' -f2 | sed -e 's/^[[:space:]]*//g'`
printf "%s %s %s\n" "$check_mem_total_str" "${line_str1:${#check_mem_total_str}}" "$mem_total"

echo ""
echo "  ================================================================="
echo "  Select Java version"
echo "  ================================================================="
echo ""
echo "    1. Oracle Java (JDK) 1.6 -> /engn001/java/1.6.0u45_64"
echo "    2. Oracle Java (JDK) 1.7 -> /engn001/java/1.7.0u80_64"
echo ""
echo -n "  [ 1 / 2 ] : "
read java_version

echo ""
if [ $java_version -eq 1 ]; then
  printf "%s %s"  "$check_java6_str" "${line_str1:${#check_java6_str}}"
  if [ -f "/engn001/java/1.6.0u45_64/bin/java" ]; then
    echo " [Success] (/engn001/java/1.6.0u45_64/bin/java)"
    echo ""
    /engn001/java/1.6.0u45_64/bin/java -version
  else
    echo " [Fail]"
    echo ""
    echo "   1. Download <jdk-6u45-linux-x64.bin> from http://www.oracle.com/technetwork/java/javase/downloads/java-archive-downloads-javase6-419409.html#jdk-6u45-oth-JPR and put file into /engn001/java !"
    echo "   2. Execute file on /engn001/java/ and mv [jdk1.6.0_45] to [1.6.0u45_64]"
    echo "   3. There is [/engn001/java/1.6.0u45_64/bin/java]"
  fi
elif [ $java_version -eq 2 ]; then
  printf "%s %s"  "$check_java7_str" "${line_str1:${#check_java7_str}}"
  if [ -f "/engn001/java/1.7.0u80_64/bin/java" ]; then
    echo " [Success] (/engn001/java/1.7.0u80_64/bin/java)"
    echo ""
    /engn001/java/1.7.0u80_64/bin/java -version
  else
    echo " [Fail]"
    echo ""
    echo "   1. Download <jdk-7u80-linux-x64.tar.gz> from http://www.oracle.com/technetwork/java/javase/downloads/java-archive-downloads-javase7-521261.html#jdk-7u80-oth-JPR and put file into /engn001/java !"
    echo "   2. Extract file on /engn001/java/ and mv [jdk1.7.0_80] to [1.7.0u80_64]"
    echo "   3. There is [/engn001/java/1.7.0u80_64/bin/java]"
  fi
else
  echo ""
  echo "  Error. Invalid java."
  echo ""
  exit 1
fi

echo ""
echo ""

