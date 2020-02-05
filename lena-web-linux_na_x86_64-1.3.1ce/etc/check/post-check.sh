#!/bin/sh

### Name    : post-check.sh @ JSTK
### Author  : jinschoi
### Version : 0.941
### Date    : 2016-03-28

usage() {
  echo " Usage :"
  echo "  ./post-check.sh -t [lena-type] -h [lena-home] -v [lena-version] -o [output]"
  echo ""
  echo "  -t (--type) : lena-manager(manager)"
  echo "                lena-server(server)"
  echo "                lena-server-agent(agent)"
  echo "                lena-web-server(web)"
  echo "                lena-web-server-agent(web-agent)"
  echo "                lena-session-server(session)"
  echo ""
  echo " Example :"
  echo "  $ ./post-check.sh -t lena-server -v 1.1"
  echo ""
}
print_k_v() {
  printf "| %-20s | %s\n" "$1" "$2"
}
print_k_v_raw() {
  printf "%s^%s\n" "$1" "$2"
}
print_t_l_s() {
  printf "+----------------------+--------------------------------------------------------------------\n"
}
print_t_l_e() {
  printf "+----------------------+--------------------------------------------------------------------\n\n"
}
get_value() {
  echo $1 | cut -d'=' -f2 | sed -e 's/"//g' | sed -e 's/\/>//g'
}
get_ltrim_strip_field2() {
  echo $1 | sed -e 's/^[[:space:]]*//' | sed -e 's/"//g' | cut -d' ' -f2
}
get_ltrim_strip_varlable_field2() {
  echo $1 | sed -e 's/^[[:space:]]*//' | sed -e 's/["|$|{|}]//g' | cut -d' ' -f2
}
get_apa_custom_log() {
  if [[ $1 == *"rotatelog"* ]]; then
    apa_custom_log1=`echo $1 | cut -d' ' -f3 | awk -F "/" '{print $NF}'`
  else
    apa_custom_log1=`echo $1 | cut -d' ' -f2 | awk -F "/" '{print $NF}'`
  fi
  echo ${apa_custom_log1//\"/}
}
get_apa_error_log() {
  if [[ $1 == *"rotatelog"* ]]; then
    echo $1 | cut -d' ' -f2 | sed -e 's/\"//g' | awk -F "/" '{print $NF}'
  else
    echo $1 | cut -d' ' -f1 | sed -e 's/\"//g' | awk -F "/" '{print $NF}'
  fi

}
display_lena_manager() {
  lena_manager_port=`grep ' SERVICE_PORT=' $LENA_HOME/bin/env-manager.sh | cut -d'=' -f2`
  lena_manager_server_port=`grep '^dataudp.port=' $LENA_HOME/conf/manager.conf | cut -d'=' -f2`

  if [ -f "$LENA_HOME/bin/start-manager.sh" ]; then
    lena_manager_start_script=$LENA_HOME/bin/start-manager.sh
  fi
  if [ -f "$LENA_HOME/bin/stop-manager.sh" ]; then
    lena_manager_stop_script=$LENA_HOME/bin/stop-manager.sh
  fi

  if [ "$OUTPUT" == "raw" ]; then
    echo "== lena_manager_start"
    echo "process_start"
    ps -ef | grep java | grep "Dlena.name=lena-manager" | grep $LENA_HOME | grep -v grep
    echo "process_end"
    print_k_v_raw "start_script" "$lena_manager_start_script"
    print_k_v_raw "stop_script" "$lena_manager_stop_script"
    print_k_v_raw "port" "$lena_manager_port"
    print_k_v_raw "server_port" "$lena_manager_server_port"
    print_k_v_raw "url" "http://$lena_ip_address:$lena_manager_port/lena"
    echo "== lena_manager_end"
  else
    echo "  <> LENA Manager"
    echo ""
    ps -ef | grep java | grep "Dlena.name=lena-manager" | grep $LENA_HOME | grep -v grep
    echo ""
    print_t_l_s
    print_k_v "Start Script" "$lena_manager_start_script"
    print_k_v "Stop Script" "$lena_manager_stop_script"
    print_k_v "Manager Port" "$lena_manager_port"
    print_k_v "Manager Server Port" "$lena_manager_server_port"
    print_k_v "Manager URL" "http://$lena_ip_address:$lena_manager_port/lena"
    print_t_l_e
  fi
}
display_lena_server_agent() {
  lena_server_agent_port=`grep "^agent.server.port=" $LENA_HOME/conf/agent.conf | cut -d'=' -f2`
  if [ -f "$LENA_HOME/bin/start-agent.sh" ]; then
    lena_server_agent_start_script=$LENA_HOME/bin/start-agent.sh
  fi
  if [ -f "$LENA_HOME/bin/stop-agent.sh" ]; then
    lena_server_agent_stop_script=$LENA_HOME/bin/stop-agent.sh
  fi

  if [ "$OUTPUT" == "raw" ]; then
    echo "== lena_server_agent_start"
    echo "process_start"
    ps -ef | grep java | grep 'argo.node.agent.server.NodeAgentServer -start' | grep "$LENA_HOME" | grep -v grep
    echo "process_end"
    print_k_v_raw "start_script" "$lena_server_agent_start_script"
    print_k_v_raw "stop_script" "$lena_server_agent_stop_script"
    print_k_v_raw "port" "$lena_server_agent_port"
    echo "== lena_server_agent_end"
  else
    echo "  <> LENA Server Agent"
    echo ""
    ps -ef | grep java | grep 'argo.node.agent.server.NodeAgentServer -start' | grep "$LENA_HOME" | grep -v grep
    echo ""
    print_t_l_s
    print_k_v "Start Script" "$lena_server_agent_start_script"
    print_k_v "Stop Script" "$lena_server_agent_stop_script"
    print_k_v "Agent Port" "$lena_server_agent_port"
    print_t_l_e
  fi
}
display_lena_server() {
  inst_count=0

  for inst in `cd $LENA_HOME/servers; ls -d */`
  do
    inst_count=$(($inst_count + 1))

    inst=${inst%%/}

    lena_inst_ps=`ps -ef | grep java | grep lena | grep ${inst} | grep -v grep`
    lena_inst_user=`echo $lena_inst_ps | awk '{print $1}'`
    lena_inst_home=$LENA_HOME/servers/$inst

if [ -f "$lena_inst_home/conf/server.xml" ]; then

    . $lena_inst_home/env.sh

    ps_array=($lena_inst_ps)
    for element in "${ps_array[@]}"
    do
      if [[ $element == *"/bin/java"* ]]; then
        lena_inst_java=`echo $element | sed -e 's/\/bin\/java//g'`
      elif [[ $element == "-DjvmRoute="* ]]; then
        lena_inst_jvm_route=`echo $element | cut -d'=' -f2`
      elif [[ $element == "-Xms"* ]]; then
        lena_inst_xms=`echo $element | cut -d's' -f2`
      elif [[ $element == "-Xmx"* ]]; then
        lena_inst_xmx=`echo $element | cut -d'x' -f2`
      elif [[ $element == "-XX:MaxPermSize"* ]]; then
        lena_inst_max_perm_size=`echo $element | cut -d'=' -f2`
      elif [[ $element == "-Dport.http="* ]]; then
        lena_inst_port_http=`echo $element | cut -d'=' -f2`
      elif [[ $element == "-Dport.ajp="* ]]; then
        lena_inst_port_ajp=`echo $element | cut -d'=' -f2`
      elif [[ $element == "-Xloggc:"* ]]; then
        lena_inst_gc_log1=`echo $element | cut -d':' -f2 | awk -F "/" '{print $NF}'`
        lena_inst_gc_log_date=`echo $lena_inst_gc_log1 | awk -F "." '{print $(NF-1)}'`
        lena_inst_gc_log=`echo $lena_inst_gc_log1 | sed -e "s/$lena_inst_gc_log_date/*/g"`
      elif [[ $element == "-XX:HeapDumpPath="* ]]; then
        lena_inst_heap_dump_path=`echo $element | cut -d'=' -f2`
      elif [[ $element == "-XX:+Use"* ]]; then
        if [[ $element == "-XX:+UseSerialGC"* ]]; then
          lena_inst_gc_policy="SerialGC - Serial Collector"
        elif [[ $element == "-XX:+UseParallelGC" ]]; then
          lena_inst_gc_policy="ParallelGC - Parallel Collector"
        elif [[ $element == "-XX:+UseParallelOldGC" ]]; then
          lena_inst_gc_policy="ParallelOldGC - Parallel Collector (Old Generation)"
        elif [[ $element == "-XX:+UseConcMarkSweepGC" ]]; then
          lena_inst_gc_policy="ConcMarkSweepGC - CMS Collector"
        elif [[ $element == "-XX:+UseG1GC" ]]; then
          lena_inst_gc_policy="G1GC - G1 Collector"
        fi
      fi
    done

    lena_inst_java_version=`$lena_inst_java/bin/java -fullversion 2>&1 | sed -e 's/java full version //g' | sed -e 's/"//g'`

    ls $lena_inst_home/lib/lena-advertiser-* > /dev/null 2>&1
    if [ $? -eq 0 ]; then
      lena_inst_agent_ver=`echo \`ls $lena_inst_home/lib/lena-advertiser-*\` | awk -F "-" '{print $NF}' | sed -e 's/.jar//g'`
    else
       lena_inst_agent_ver='Unknown'
    fi

    server_xml=$lena_inst_home/conf/server.xml
    context_xml=$lena_inst_home/conf/context.xml

    is_conf_line=0

    while read -r conf_line
    do
      if [ "$conf_line" == "<!-- Define an AJP 1.3 Connector on port 8009 -->" ]; then
        is_conf_line=1
      fi
      if [ $is_conf_line == 1 ]; then
        if [[ "$conf_line" == *"maxThreads="* ]]; then
          lena_inst_port_ajp_max_threads1=$conf_line
          if_read=0
          break
        fi
      fi
    done < $server_xml

    ajp_array=($lena_inst_port_ajp_max_threads1)
    for element in "${ajp_array[@]}"
    do
      if [[ $element == *"maxThreads"* ]]; then
        lena_inst_port_ajp_max_threads=`echo $element | cut -d'=' -f2 | sed -e 's/\"//g'`
      fi
    done

    lena_inst_catalina_log1=`cd $lena_inst_home/logs; ls $inst*`
    lena_inst_catalina_log=${lena_inst_catalina_log1%.*}

    
    lena_inst_datasource_count_server_xml=`grep 'argo.server.jdbc.pool.ArgoDataSourceFactory' $server_xml | wc -l`
    lena_inst_datasource_count_context_xml=`grep 'argo.server.jdbc.pool.ArgoDataSourceFactory' $context_xml | wc -l`

    if [ $lena_inst_datasource_count_server_xml -gt 0 ]; then
      IFS=$IFS_NEW_LINE
      lena_inst_datasource_count=$lena_inst_datasource_count_server_xml
      datasource_array=(`grep 'argo.server.jdbc.pool.ArgoDataSourceFactory' $server_xml`)
    elif [ $lena_inst_datasource_count_context_xml -gt 0 ]; then
      IFS=$IFS_NEW_LINE
      lena_inst_datasource_count=$lena_inst_datasource_count_context_xml
      datasource_array=(`grep 'argo.server.jdbc.pool.ArgoDataSourceFactory' $context_xml`)
    else
      lena_inst_datasource_count=0 
    fi

    if [ "$OUTPUT" == "raw" ]; then
      echo "== lena_server_start^inst_count=$inst_count^inst_name=$inst"
      echo "process_start"
      ps -ef | grep java | grep lena | grep ${inst} | grep -v grep
      echo "process_end"
      print_k_v_raw "host_name" "$lena_host_name"
      print_k_v_raw "cpu_count" "$lena_cpu_count"
      print_k_v_raw "mem_total" "$lena_mem_total"
      print_k_v_raw "ip_address" "$lena_ip_address"
      print_k_v_raw "os_info" "$lena_os_info"
      print_k_v_raw "java" "$lena_inst_java"
      print_k_v_raw "java_version" "$lena_inst_java_version"
      print_k_v_raw "agent_ver" "$lena_inst_agent_ver"
      print_k_v_raw "was_user" "$lena_inst_user"
      print_k_v_raw "inst_home" "$lena_inst_home"
      print_k_v_raw "start_script" "start.sh"
      print_k_v_raw "stop_script" "stop.sh"
      print_k_v_raw "jvm_route" "$lena_inst_jvm_route"
      print_k_v_raw "xms" "$lena_inst_xms"
      print_k_v_raw "xmx" "$lena_inst_xmx"
      print_k_v_raw "max_perm_size" "$lena_inst_max_perm_size"
      print_k_v_raw "port_http" "$lena_inst_port_http"
      print_k_v_raw "port_ajp" "$lena_inst_port_ajp"
      print_k_v_raw "port_ajp_max_threads" "$lena_inst_port_ajp_max_threads"
      print_k_v_raw "log_dir" "${LOG_HOME}"
      print_k_v_raw "catalina_log" "$lena_inst_catalina_log*"
      print_k_v_raw "gc_log" "$lena_inst_gc_log"
      print_k_v_raw "gc_policy" "$lena_inst_gc_policy"
      print_k_v_raw "heap_dump_path" "$lena_inst_heap_dump_path"
      if [ $lena_inst_datasource_count -eq 0 ]; then
        print_k_v_raw "datasource" "no_datasource"
      else
        datasource_seq=1
        IFS=" "
        for element in "${datasource_array[@]}"
        do
          _get_datasource_element_value

          print_k_v_raw "datasource_name" "$(get_value "$lena_inst_datasource_name")"
          print_k_v_raw "datasource_url" "$(get_value "$lena_inst_datasource_url")"
          print_k_v_raw "datasource_user" "$(get_value "$lena_inst_datasource_user")"
          print_k_v_raw "datasource_initial" "$(get_value "$lena_inst_datasource_initial_size")"
          print_k_v_raw "datasource_max" "$(get_value "$lena_inst_datasource_max_active")"
          ((datasource_seq = datasource_seq + 1))
        done
      fi
      if [ -f "$lena_inst_home/conf/session.conf" ]; then
        zodiac_conf=$lena_inst_home/conf/session.conf
        if [ `grep '^server.embedded=true$' $zodiac_conf | wc -l` -eq 1 ]; then
          zodiac_type="Embedded"
        elif [ `grep '^server.embedded=false$' $zodiac_conf | wc -l` -eq 1 ]; then
          zodiac_type="Client Mode"
        fi
        print_k_v_raw "cluster_type" "$zodiac_type"
        print_k_v_raw "cluster_primary_host" "`grep '^primary.host=' $zodiac_conf | cut -d'=' -f2`"
        print_k_v_raw "cluster_primary_port" "`grep '^primary.port=' $zodiac_conf | cut -d'=' -f2`"
        print_k_v_raw "cluster_secondary_host" "`grep '^secondary.host=' $zodiac_conf | cut -d'=' -f2`"
        print_k_v_raw "cluster_secondary_port" "`grep '^secondary.port=' $zodiac_conf | cut -d'=' -f2`"
      else
        print_k_v_raw "Cluster Type" "No Cluster Configured"
      fi
      echo "== lena_server_end"
    else
      echo "  <> LENA Server - $inst_count. $inst"
      echo ""
      ps -ef | grep java | grep lena | grep ${inst} | grep -v grep
      echo ""
      print_t_l_s
      print_k_v "Hostname" "$lena_host_name"
      print_k_v "CPU Count" "$lena_cpu_count"
      print_k_v "Memory Total" "$lena_mem_total"
      print_k_v "IP Address (eth)" "$lena_ip_address"
      print_k_v "OS" "$lena_os_info"
      print_t_l_s
      print_k_v "Java" "$lena_inst_java"
      print_k_v "Java Version" "$lena_inst_java_version"
      print_k_v "LENA Version" "$lena_inst_agent_ver"
      print_k_v "WAS User" "$lena_inst_user"
      print_k_v "Instance Home" "$lena_inst_home"
      print_k_v "Start Script" "start.sh"
      print_k_v "Stop Script" "stop.sh"
      print_k_v "JVM Route" "$lena_inst_jvm_route"
      print_k_v "Heap Initial" "$lena_inst_xms"
      print_k_v "Heap Max" "$lena_inst_xmx"
      print_k_v "Permanent Max" "$lena_inst_max_perm_size"
      print_k_v "HTTP Port" "$lena_inst_port_http"
      print_k_v "AJP Port" "$lena_inst_port_ajp"
      print_k_v "AJP Max Thread" "$lena_inst_port_ajp_max_threads"
      print_k_v "Log Directory" "${LOG_HOME}"
      print_k_v "Log File" "$lena_inst_catalina_log*"
      print_k_v "GC Log File" "$lena_inst_gc_log"
      print_k_v "GC Policy" "$lena_inst_gc_policy"
      print_k_v "Heap Dump Path" "$lena_inst_heap_dump_path"
      print_t_l_s
      if [ $lena_inst_datasource_count -eq 0 ]; then
        print_k_v "DataSource" "No DataSource Configured"
      else
        datasource_seq=1
        IFS=" "
        for element in "${datasource_array[@]}"
        do
          _get_datasource_element_value
  
          print_k_v "DataSource" "[$datasource_seq] $(get_value "$lena_inst_datasource_name")"
          print_k_v " - URL" "    - $(get_value "$lena_inst_datasource_url")"
          print_k_v " - User" "    - $(get_value "$lena_inst_datasource_user")"
          print_k_v " - Initial" "    - $(get_value "$lena_inst_datasource_initial_size")"
          print_k_v " - Max" "    - $(get_value "$lena_inst_datasource_max_active")"
          ((datasource_seq = datasource_seq + 1))
        done
      fi
      print_t_l_s

      if [ -f "$lena_inst_home/conf/session.conf" ]; then
        zodiac_conf=$lena_inst_home/conf/session.conf
        if [ `grep '^server.embedded=true$' $zodiac_conf | wc -l` -eq 1 ]; then
          zodiac_type="Embedded"
        elif [ `grep '^server.embedded=false$' $zodiac_conf | wc -l` -eq 1 ]; then
          zodiac_type="Client Mode"
        fi
        print_k_v "Cluster Type" "$zodiac_type"
        print_k_v "Primary Host" "`grep '^primary.host=' $zodiac_conf | cut -d'=' -f2`"
        print_k_v "Primary Port" "`grep '^primary.port=' $zodiac_conf | cut -d'=' -f2`"
        print_k_v "Secondary Host" "`grep '^secondary.host=' $zodiac_conf | cut -d'=' -f2`"
        print_k_v "Secondary Port" "`grep '^secondary.port=' $zodiac_conf | cut -d'=' -f2`"
      else
        print_k_v "Cluster Type" "No Cluster Configured"
      fi
      print_t_l_e
    fi
  fi
  done
}
display_lena_web_server_agent() {
  apache_server_agent_port=`grep "^agent.server.port=" $LENA_HOME/conf/agent.conf | cut -d'=' -f2`
  if [ -f "$LENA_HOME/bin/start-agent.sh" ]; then
    apache_server_agent_start_script=$LENA_HOME/bin/start-agent.sh
  fi
  if [ -f "$LENA_HOME/bin/stop-agent.sh" ]; then
    apache_server_agent_stop_script=$LENA_HOME/bin/stop-agent.sh
  fi

  if [ "$OUTPUT" == "raw" ]; then
    echo "== apache_server_agent_start"
    echo "process_start"
    ps -ef | grep java | grep 'argo.node.agent.server.NodeAgentServer -start' | grep "$LENA_HOME" | grep -v grep
    echo "process_end"
    print_k_v_raw "start_script" "$apache_server_agent_start_script"
    print_k_v_raw "stop_scriptt" "$apache_server_agent_stop_script"
    print_k_v_raw "agent_port" "$apache_server_agent_port"
    echo "== apache_server_agent_end"
  else
    echo "  <> Web Server Agent"
    echo ""
    ps -ef | grep java | grep 'argo.node.agent.server.NodeAgentServer -start' | grep "$LENA_HOME" | grep -v grep
    echo ""
    print_t_l_s
    print_k_v "Start Script" "$apache_server_agent_start_script"
    print_k_v "Stop Script" "$apache_server_agent_stop_script"
    print_k_v "Agent Port" "$apache_server_agent_port"
    print_t_l_e
  fi
}
display_lena_web_server() {
  inst_count=0

  for inst in `cd $LENA_HOME/servers; ls -d */`
  do
    inst_count=$(($inst_count + 1))

    inst=${inst%%/}

    apa_inst_home=$LENA_HOME/servers/$inst

if [ -f "$apa_inst_home/conf/httpd.conf" ]; then

    apa_inst_ps=`ps -ef | grep httpd | grep ${inst} | grep -v grep | head -1`
    apa_inst_user=`echo $apa_inst_ps | awk '{print $1}'`
    apa_inst_ver=`$LENA_HOME/modules/lena-web-pe/bin/httpd -v | grep version`

    apa_inst_ver=`$LENA_HOME/modules/lena-web-pe/bin/httpd -v | grep version | sed -e 's/Server version: //g'`
    env_sh=$apa_inst_home/env.sh

#    echo ""
#    ps -ef | grep httpd | grep ${inst} | grep -v grep
#    echo ""

    . $env_sh

    httpd_conf=$apa_inst_home/conf/httpd.conf
    httpd_default_conf=$apa_inst_home/conf/extra/httpd-default.conf
    workers_properties=$apa_inst_home/conf/extra/workers.properties

    apa_inst_listen_http=`grep "^export SERVICE_PORT=" $env_sh | cut -d'=' -f2`
    netstat -an | grep tcp | grep ":$apa_inst_listen_http" | grep LISTEN  > /dev/null
    if [ $? -eq 0 ]; then
      is_apa_inst_listen_http="Listen"
    else
      is_apa_inst_listen_http="Not Listen"
    fi

    apa_inst_listen_https=`grep "^export HTTPS_SERVICE_PORT=" $env_sh | cut -d'=' -f2`
    netstat -an | grep tcp | grep ":$apa_inst_listen_https" | grep LISTEN  > /dev/null
    if [ $? -eq 0 ]; then
      is_apa_inst_listen_https="Listen"
    else
      is_apa_inst_listen_https="Not Listen"
    fi

    apa_inst_documrnt_root1=`get_ltrim_strip_varlable_field2 "\`grep 'DocumentRoot ' $httpd_conf | grep -v '#'\`"`
    apa_inst_document_root=`grep "^export $apa_inst_documrnt_root1=" $env_sh | cut -d'=' -f2`
    if [ -d "$apa_inst_document_root" ]; then
      apa_inst_document_root_permission=`ls -ld $apa_inst_document_root | awk {'print $1'}`
    else
      apa_inst_document_root_permission="No Directory"
    fi

    apa_inst_trace_enable=`grep "^TraceEnable " $httpd_conf | cut -d' ' -f2`
    apa_inst_keep_alive=`grep "^KeepAlive " $httpd_default_conf | cut -d' ' -f2`
    apa_inst_keep_alive_timeout=`grep "^KeepAliveTimeout " $httpd_default_conf | cut -d' ' -f2`
    apa_inst_server_tokens=`grep "^ServerTokens " $httpd_default_conf | cut -d' ' -f2`
    apa_inst_server_signature=`grep "^ServerSignature " $httpd_default_conf | cut -d' ' -f2`

    apa_inst_custom_log=`get_apa_custom_log "\`grep "CustomLog " $httpd_conf | grep -v "#" | sed -e 's/^[[:space:]]*//'\`"`
    apa_inst_error_log=`get_apa_error_log "\`grep "^ErrorLog " $httpd_conf | cut -d' ' -f2-\`"`

    ## MPM

    is_mpm_line=0
    while read mpm_line
    do
      if [ $is_mpm_line -eq 0 -a "$mpm_line" == "<IfModule mpm_worker_module>" ]; then
        is_mpm_line=1
      elif [ $is_mpm_line -eq 1 -a "$mpm_line" == "</IfModule>" ]; then
        break
      fi
      if [ $is_mpm_line -eq 1 ]; then
        if [[ "$mpm_line" == *"StartServers"* ]]; then
          tmp_str=${mpm_line/"StartServers"}
          apa_inst_mpm_start_servers=${tmp_str//[[:blank:]]/}
        elif [[ "$mpm_line" == *"MaxClients"* ]]; then
          tmp_str=${mpm_line/"MaxClients"}
          apa_inst_mpm_max_clients=${tmp_str//[[:blank:]]/}
        elif [[ "$mpm_line" == *"ThreadsPerChild"* ]]; then
          tmp_str=${mpm_line/"ThreadsPerChild"}
          apa_inst_mpm_threads_per_child=${tmp_str//[[:blank:]]/}
        fi
      fi
    done < $apa_inst_home/conf/extra/httpd-mpm.conf

    if [ "$OUTPUT" == "raw" ]; then
      echo "== apache_server_start^inst_count=$inst_count^inst_name=$inst"
      echo "process_start"
      ps -ef | grep httpd | grep ${inst} | grep -v grep
      echo "process_end"
      print_k_v_raw "host_name" "$lena_host_name"
      print_k_v_raw "cpu_count" "$lena_cpu_count"
      print_k_v_raw "mem_total" "$lena_mem_total"
      print_k_v_raw "ip_address" "$lena_ip_address"
      print_k_v_raw "apache_ver" "$apa_inst_ver"
      print_k_v_raw "web_user" "$apa_inst_user"
      print_k_v_raw "inst_home Home" "$apa_inst_home"
      print_k_v_raw "start_script" "start.sh"
      print_k_v_raw "stop_script" "stop.sh"
      print_k_v_raw "http_port" "$apa_inst_listen_http ($is_apa_inst_listen_http)"
      print_k_v_raw "https_port" "$apa_inst_listen_https ($is_apa_inst_listen_https)"
      print_k_v_raw "access_log" "$apa_inst_custom_log"
      print_k_v_raw "error_log" "$apa_inst_error_log"
      print_k_v_raw "document_root" "$apa_inst_document_root ($apa_inst_document_root_permission)"
      print_k_v_raw "keep_alive" "$apa_inst_keep_alive"
      print_k_v_raw "keep_alive_timeout" "$apa_inst_keep_alive_timeout"
      print_k_v_raw "trace_enable" "$apa_inst_trace_enable"
      print_k_v_raw "server_tokens" "$apa_inst_server_tokens"
      print_k_v_raw "server_signature" "$apa_inst_server_signature"
      print_k_v_raw "mpm_start_servers" "$apa_inst_mpm_start_servers"
      print_k_v_raw "mpm_max_clients" "$apa_inst_mpm_max_clients"
      print_k_v_raw "mpm_threads_per_child" "$apa_inst_mpm_threads_per_child"

      vhost_seq=1
      for vhost in `cd $apa_inst_home/conf/extra/vhost; ls`
      do
        vhost_conf=$apa_inst_home/conf/extra/vhost/$vhost
        vhost_name=`echo $vhost | sed -e 's/.conf//g'`
        print_k_v_raw "vhost_name" "$vhost_seq $vhost_name"
  
        _get_vhost
        _get_urimap

        print_k_v_raw "vhost_urimap" "`(IFS=$','; echo \"${urimap_array[*]}\")`"
        print_k_v_raw "vhost_document_root" "$apa_inst_vhost_document_root"
        print_k_v_raw "vhost_access_log" "$apa_inst_vhost_custom_log"
        print_k_v_raw "vhost_error_log" "$apa_inst_vhost_error_log"

        ((vhost_seq = vhost_seq + 1))
      done
    else
      echo "  <> LENA Web Server - $inst_count. $inst"
      echo ""
      ps -ef | grep httpd | grep ${inst} | grep -v grep
      echo ""
      print_t_l_s
      print_k_v "Hostname" "$lena_host_name"
      print_k_v "CPU Count" "$lena_cpu_count"
      print_k_v "Memory Total" "$lena_mem_total"
      print_k_v "IP Address (eth)" "$lena_ip_address"
      print_k_v "OS" "$lena_os_info"
      print_t_l_s
      print_k_v "LENA Version" "$apa_inst_ver"
      print_k_v "WEB User" "$apa_inst_user"
      print_k_v "Instance Home" "$apa_inst_home"
      print_k_v "Start Script" "start.sh"
      print_k_v "Stop Script" "stop.sh"
      print_k_v "HTTP Port" "$apa_inst_listen_http ($is_apa_inst_listen_http)"
      print_k_v "HTTPS Port" "$apa_inst_listen_https ($is_apa_inst_listen_https)"
      print_k_v "Access Log" "$apa_inst_custom_log"
      print_k_v "Error Log" "$apa_inst_error_log"
      print_k_v "Document Root" "$apa_inst_document_root ($apa_inst_document_root_permission)"
      print_k_v "KeepAlive" "$apa_inst_keep_alive"
      print_k_v "KeepAliveTimeout" "$apa_inst_keep_alive_timeout"
      print_k_v "TraceEnable" "$apa_inst_trace_enable"
      print_k_v "ServerTokens" "$apa_inst_server_tokens"
      print_k_v "ServerSignature" "$apa_inst_server_signature"
      print_k_v "StartServers" "$apa_inst_mpm_start_servers"
      print_k_v "MaxClients" "$apa_inst_mpm_max_clients"
      print_k_v "ThreadsPerChild" "$apa_inst_mpm_threads_per_child"
      print_t_l_s

    vhost_seq=1
    for vhost in `cd $apa_inst_home/conf/extra/vhost; ls`
    do
      vhost_conf=$apa_inst_home/conf/extra/vhost/$vhost
      vhost_name=`echo $vhost | sed -e 's/.conf//g'`
      print_k_v "Virtual Host" "[$vhost_seq] $vhost_name"

      _get_vhost
      _get_urimap

      print_k_v "- Uriworkermap" "    - `(IFS=$','; echo \"${urimap_array[*]}\")`"
      print_k_v "- Document Root" "    - $apa_inst_vhost_document_root"
      print_k_v "- Access Log" "    - $apa_inst_vhost_custom_log"
      print_k_v "- Error Log" "    - $apa_inst_vhost_error_log"
    done

    print_t_l_s

    worker_seq=1
    lb_seq=1

    IFS=","
    for lb in `grep '^worker.list=' $workers_properties | cut -d'.' -f2 | sed -e 's/list=//g'`
    do
      if [ "$lb" != "jkstatus" ]; then
        lb_name1=`echo $lb | sed -e 's/[$|{|}]//g'`
        lb_name=`grep "$lb_name1=" $env_sh | cut -d'=' -f2`
        print_k_v "Load Balancer" "[$lb_seq] $lb_name"

        for lb_worker in `grep '.balance_workers' $workers_properties | grep -v "^#" | cut -d'=' -f2`
        do
          print_k_v "- Worker Name" "    ($worker_seq) $lb_worker"

          IFS=$IFS_NEW_LINE
          for all_worker in `grep '^worker.' $workers_properties \
            | grep -v '^worker.list' \
            | grep -v '^worker.template' \
            | grep -v '^worker.jkstatus' \
            | cut -d'.' -f2 \
            | sort \
            | uniq`
          do
            if [ "$lb_worker" == "$all_worker" ]; then
              print_k_v "  - Host" "        - `grep "${all_worker}.host=" $workers_properties | cut -d'=' -f2`"
              print_k_v "  - Port" "        - `grep "${all_worker}.port=" $workers_properties | cut -d'=' -f2`"
              ((worker_seq++))
            fi
          done
        done
        ((lb_seq++))
      fi
    done
    print_t_l_e
    fi
fi
  done
}
display_lena_session_server() {
  inst_count=0

  for inst in `cd $LENA_HOME/servers; ls -d */`
  do
    inst_count=$(($inst_count + 1))

    inst=${inst%%/}

    lena_session_ps=`ps -ef | grep java | grep lena | grep ${inst} | grep -v grep`
    lena_session_user=`echo $lena_session_ps | awk '{print $1}'`
    lena_session_home=$LENA_HOME/servers/$inst

  if [ -f "$lena_session_home/session.conf" ]; then

    . $lena_session_home/env.sh

    ps_array=($lena_session_ps)
    for element in "${ps_array[@]}"
    do
      if [[ $element == *"/bin/java"* ]]; then
        lena_session_java=`echo $element | sed -e 's/\/bin\/java//g'`
      elif [[ $element == "-Xmx"* ]]; then
        lena_session_xmx=`echo $element | cut -d'x' -f2`
      fi
    done

    lena_session_java_version=`$lena_session_java/bin/java -fullversion 2>&1 | sed -e 's/java full version //g' | sed -e 's/"//g'`

    session_conf=$lena_session_home/session.conf

    if [ "$OUTPUT" == "raw" ]; then
      echo "== lena_session_server_start^inst_count=$inst_count^inst_name=$inst"
      echo "process_start"
      ps -ef | grep java | grep lena | grep ${inst} | grep -v grep
      echo "process_end"
      print_k_v_raw "host_name" "$lena_host_name"
      print_k_v_raw "cpu_count" "$lena_cpu_count"
      print_k_v_raw "mem_total" "$lena_mem_total"
      print_k_v_raw "ip_address" "$lena_ip_address"
      print_k_v_raw "os_info" "$lena_os_info"
      print_k_v_raw "java" "$lena_session_java"
      print_k_v_raw "java_version" "$lena_session_java_version"
      print_k_v_raw "run_user" "$lena_session_user"
      print_k_v_raw "session_home" "$lena_session_home"
      print_k_v_raw "start_script" "start.sh"
      print_k_v_raw "stop_script" "stop.sh"
      print_k_v_raw "xmx" "$lena_session_xmx"
      print_k_v_raw "log_dir" "${LOG_HOME}"
      print_k_v_raw "primary_port" "`grep '^primary.port=' $session_conf | cut -d'=' -f2`"
      print_k_v_raw "session_timeout" "`grep '^server.expire.sec=' $session_conf | cut -d'=' -f2`s"
      print_k_v_raw "secondary_host" "`grep '^secondary.host=' $session_conf | cut -d'=' -f2`"
      print_k_v_raw "secondary_port" "`grep '^secondary.port=' $session_conf | cut -d'=' -f2`"
      echo "== lena_session_server_end"
    else
      echo "  <> LENA Server - $inst_count. $inst"
      echo ""
      ps -ef | grep java | grep lena | grep ${inst} | grep -v grep
      echo ""
      print_t_l_s
      print_k_v "Hostname" "$lena_host_name"
      print_k_v "CPU Count" "$lena_cpu_count"
      print_k_v "Memory Total" "$lena_mem_total"
      print_k_v "IP Address (eth)" "$lena_ip_address"
      print_k_v "OS" "$lena_os_info"
      print_t_l_s
      print_k_v "Java" "$lena_session_java"
      print_k_v "Java Version" "$lena_session_java_version"
      print_k_v "Run User" "$lena_session_user"
      print_k_v "Session Home" "$lena_session_home"
      print_k_v "Start Script" "start.sh"
      print_k_v "Stop Script" "stop.sh"
      print_k_v "Heap Max" "$lena_session_xmx"
      print_k_v "Log Directory" "${LOG_HOME}"
      print_k_v "Primary Port" "`grep '^primary.port=' $session_conf | cut -d'=' -f2`"
      print_k_v "Session Timeout" "`grep '^server.expire.sec=' $session_conf | cut -d'=' -f2`s"
      print_k_v "Secondary IP" "`grep '^secondary.host=' $session_conf | cut -d'=' -f2`"
      print_k_v "Secondary Port" "`grep '^secondary.port=' $session_conf | cut -d'=' -f2`"
      print_t_l_e
    fi
  fi
  done
}
_get_datasource_element_value() {
  for key in `echo $element`
  do
    if [[ $key == "name="* ]]; then
      lena_inst_datasource_name=$key
    elif [[ $key == "url="* ]]; then
      lena_inst_datasource_url=$key
    elif [[ $key == "username="* ]]; then
      lena_inst_datasource_user=$key
    elif [[ $key == "initialSize="* ]]; then
      lena_inst_datasource_initial_size=$key
    elif [[ $key == "maxActive="* ]]; then
      lena_inst_datasource_max_active=$key
    fi
  done
}
_get_vhost() {
  apa_inst_vhost_document_root1=`get_ltrim_strip_varlable_field2 "\`grep 'DocumentRoot ' $vhost_conf | grep -v '#'\`"`
  apa_inst_vhost_document_root=`echo ${!apa_inst_vhost_document_root1} | cut -d'=' -f2`
  if [ -d "$apa_inst_vhost_document_root" ]; then
    apa_inst_vhost_document_root_permission=`ls -ld $apa_inst_vhost_document_root | awk {'print $1'}`
  else
    apa_inst_vhost_document_root_permission="No Directory"
  fi
  apa_inst_vhost_custom_log=`get_apa_custom_log "\`grep "CustomLog " $vhost_conf \
    | grep -v "#" | sed -e 's/^[[:space:]]*//'\`"`
  apa_inst_vhost_error_log=`get_apa_error_log "\`grep "^ErrorLog " $vhost_conf \
    | cut -d' ' -f2-\`"`
}
_get_urimap() {
  apa_inst_vhost_uriworkermap=`get_ltrim_strip_field2 "\`grep 'JkMountFile ' $vhost_conf | grep -v '#'\`"`
  echo $apa_inst_vhost_uriworkermap
  urimap_array=()
  if [ "$apa_inst_vhost_uriworkermap" != "" ]; then
    for urimap in `cat \`eval echo $apa_inst_vhost_uriworkermap\``
    do
      uri=`echo $urimap | cut -d'=' -f1 | sed -e 's/[\||\/]//g'`
      if [ "$uri" == "*" ]; then
        urimap_array+=("*")
      else
        urimap_array+=($uri)
      fi
    done
  fi
}

while [[ $# > 1 ]]
do
  key="$1"

  case $key in
      -t|--type)
      LENA_TYPE="$2"
      shift # past argument
      ;;
      -h|--home)
      LENA_HOME="$2"
      shift # past argument
      ;;
      -v|--ver)
      LENA_VER="$2"
      shift # past argument
      ;;
      -o|--output)
      OUTPUT="$2"
      shift # past argument
      ;;
      --default)
      DEFAULT=YES
      ;;
      *)
              # unknown option
      ;;
  esac
  shift # past argument or value
done

echo "type = $LENA_TYPE"
echo "home = $LENA_HOME"
echo "version = $LENA_VER"
echo "output = $OUTPUT"

IFS_NEW_LINE=$'
'

lena_host_name=`uname -n`
if [ `ifconfig -a | grep eth0 | wc -l` -gt 0 ]; then
  lena_ip_address=`ifconfig eth0 | grep 'inet addr:' | cut -d':' -f2 | awk '{print $1}'`
elif [ `ifconfig -a | grep eth1 | wc -l` -gt 0 ]; then
  lena_ip_address=`ifconfig eth1 | grep 'inet addr:' | cut -d':' -f2 | awk '{print $1}'`
fi
lena_os_info=`uname -sr`
lena_cpu_count=`grep processor /proc/cpuinfo | wc -l`
lena_mem_total=`grep MemTotal /proc/meminfo | cut -d':' -f2 | sed -e 's/^[[:space:]]*//'`

echo ""

if [ "$LENA_TYPE" == "lena-manager" ] || [ "$LENA_TYPE" == "manager" ]; then
  display_lena_manager
elif [ "$LENA_TYPE" == "lena-server-agent" ] || [ "$LENA_TYPE" == "agent" ]; then
  display_lena_server_agent
elif [ "$LENA_TYPE" == "lena-server" ] || [ "$LENA_TYPE" == "server" ] ; then
  display_lena_server
elif [ "$LENA_TYPE" == "lena-web-server-agent" ] || [ "$LENA_TYPE" == "web-agent" ]; then
  display_lena_web_server_agent
elif [ "$LENA_TYPE" == "lena-web-server" ] || [ "$LENA_TYPE" == "web" ]; then
  display_lena_web_server
elif [ "$LENA_TYPE" == "lena-session-server" ] || [ "$LENA_TYPE" == "session" ]; then
  display_lena_session_server
elif [ "$LENA_TYPE" == "default-all" ]; then
  if [ "$LENA_VER" == "" ]; then
    LENA_VER=1.3
  else
    LENA_VER=$LENA_VER
  fi

  if [ -d "/engn001/lena/${LENA_VER}/bin" ]; then
    if [ -f "/engn001/lena/${LENA_VER}/bin/start-manager.sh" ]; then
      LENA_HOME=/engn001/lena/${LENA_VER}
      display_lena_manager
    fi
    if [ -f "/engn001/lena/${LENA_VER}/bin/start-agent.sh" ]; then
      LENA_HOME=/engn001/lena/${LENA_VER}
      display_lena_server_agent
    fi
  fi
  if [ -d "/engn001/lena/${LENA_VER}/servers" ]; then
    LENA_HOME=/engn001/lena/${LENA_VER}
    display_lena_server
    display_lena_session_server
  fi
  if [ -f "/engn001/lenaw/${LENA_VER}/bin/start-agent.sh" ]; then
    LENA_HOME=/engn001/lenaw/${LENA_VER}
    display_lena_web_server_agent
  fi
  if [ -d "/engn001/lenaw/${LENA_VER}/servers" ]; then
    LENA_HOME=/engn001/lenaw/${LENA_VER}
    display_lena_web_server
  fi
else 
  usage
  exit 1
fi


