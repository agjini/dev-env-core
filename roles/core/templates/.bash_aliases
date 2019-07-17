
alias idea='~/applications/idea/bin/idea.sh > /dev/null 2>&1 &'

# maven
alias mvn='~/applications/maven/bin/mvn'
alias mci='mvn clean install'
alias mcis='mvn clean install -DskipTests'
alias mvn_set_debug_5000='export MAVEN_OPTS="-Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,address=5000,server=y,suspend=n -Xmx512m -XX:MaxPermSize=256m"'
alias mvn_set_debug_5001='export MAVEN_OPTS="-Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,address=5001,server=y,suspend=n -Xmx512m -XX:MaxPermSize=256m"'
alias mvn_set_debug_5002='export MAVEN_OPTS="-Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,address=5002,server=y,suspend=n -Xmx512m -XX:MaxPermSize=256m"'
alias mvnIntegrationTests='mvn clean install -DargLine="-DtestEnvironment=integration"'
alias mvnPurgeSnapshots='find ~/.m2/repository/ -depth -type d -name "*SNAPSHOT" -exec rm -rf {} \;'
alias q='~/applications/q'
alias test_and_push='mvn clean install && git push'
alias dc=docker-compose

function clone_group {
    if [ $# -ne 2 ]
    then
        echo "Usage : clone_group <GITLAB_ACCESS_TOKEN> <GROUP_TO_CLONE>"
        echo "    GITLAB_ACCESS_TOKEN can be generated at : https://git.livingobjects.com/profile/personal_access_tokens"
        return 1;
    fi
    TOKEN=${1};
    GROUP=${2};
    mkdir -p ${GROUP};
    cd ${GROUP};
    for PROJECT in `http https://git.livingobjects.com:443/api/v3/groups/${GROUP}?private_token=${TOKEN} | jq .projects | jq -r .[].ssh_url_to_repo`;
    do
        echo Cloning ${PROJECT};
        git clone ${PROJECT};
    done;
    cd -
}

function gitrepos_update_path {
    if [ -n "$(git --git-dir=${1} --work-tree=$(dirname ${1}) status --porcelain)" ]; then
       echo "* $(dirname ${1})" >> /tmp/gitrepos_update_report
    else
       echo "Updating repository $(dirname ${1})"
       git --git-dir=${1} --work-tree=$(dirname ${1}) pull
    fi
}
export -f gitrepos_update_path  &>/dev/null

function gitrepos_status_path {
   red="\033[0;31m"
   NC="\033[0m"
   dir="$(dirname $1)"
   changes=$(git --git-dir="$1" --work-tree=$dir status -s)

   if [ -n "$changes" ]
   then
     change_msg="[`echo $changes | wc -l` uncommitted file(s)]"
     dirty=1
   fi

   repo_gap=$(git --git-dir="$1" --work-tree=$dir rev-list --left-right @{u}...)

   if [ -n "$repo_gap" ]
   then
     ahead=`echo -e "$repo_gap" | grep '<' | wc -l`
     behind=`echo -e "$repo_gap" | grep '>' | wc -l`
     gap_msg="[need for synchronization ($ahead ahead - $behind behind)]"
     dirty=1
   fi

   if [ -n "$dirty" ]
   then
     echo -e "${red}(*)${NC} $dir $change_msg $gap_msg"
   else
     echo "$dir"
   fi
}

export -f gitrepos_status_path  &>/dev/null

function gitrepos_status_all {
   find -L ~/ -maxdepth 5 -path "*.git"  -type d  -exec bash -c 'gitrepos_status_path "{}"' \;
}

function tkillw {
    tmux kill-window -t $1
}

function tkillws {
    for i in $(eval echo {$1..$2});
    do
        echo "kill $i";
        command tmux kill-window -t ${i};
    done
}

alias tkillserver='tmux kill-server'
function trespawnw {
    # the 2 Ctrl-C are there in case you are in edition mode, the first exit the edition mode and the second kill the running process
    tmux send-keys -t ${1} "C-c"
    tmux send-keys -t ${1} "C-c"
    retries=1
    until `tmux respawn-window -t ${1}`
    do
        echo "retrying"
        sleep 0.5
        retries=$(($retries + 1))
        if [ ${retries} -gt 5 ]
        then
            echo "we tried 5 times without apparent success"
            break
        fi
    done
    echo "done"
}

function trespawnws {
    for i in $(eval echo {$1..$2});
    do
        echo "respawn $i";
        trespawnw $i
    done
}

#################################
############ ELK ################
#################################

function es_start {
    docker run -d --name es -p 9200:9200 -p 9300:9300 -v ~/applications/esdata:/usr/share/elasticsearch/data -e "discovery.type=single-node" docker.elastic.co/elasticsearch/elasticsearch:6.3.2 || docker start es
}

function es_stop {
    docker rm -f es || true
}

function es_purge {
    es_stop
    sudo rm -rf ~/applications/esdata/*
    sudo mkdir -p ~/applications/esdata
    es_start
}

#################################
############# NEO4J #############
#################################

alias neo4j_2_start='~/applications/neo4j2/bin/neo4j start'

alias neo4j_2_stop='~/applications/neo4j2/bin/neo4j stop'

function neo4j_2_dump_on_local {
    if [ $# -lt 1 ]; then
        echo -e USAGE: neo4j_2_dump_on_local ip
        return
    fi

    local IP=${1}

    ssh ${IP} 'rm -f graph.tar.gz'
    ssh ${IP} 'cd /data/neo4j/ && tar cvfpz ~/graph.tar.gz graph.db'

    neo4j_2_stop

    rm -rf ~/applications/neo4j2/data/*

    scp ${IP}:~/graph.tar.gz /tmp

    mkdir -p ~/applications/neo4j2/data
    tar xvzf /tmp/graph.tar.gz -C ~/applications/neo4j2/data

    neo4j_2_start
}

function neo4j_start {
    mkdir -p ~/applications/neo4j/data
    docker run -d --name neo4j \
        -e NEO4J_dbms_jvm_additional="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005" \
        -e NEO4J_dbms_allow__upgrade=true \
        -e NEO4J_AUTH=none \
        -e NEO4J_dbms_unmanaged__extension__classes=com.livingobjects.neo4j=/unmanaged \
        -p 7474:7474 \
        -p 7687:7687 \
        -p 5008:5005 \
        -v ~/applications/neo4j/data:/data \
        -v ~/applications/neo4j/plugins:/plugins \
        neo4j:3.4.7 || docker start neo4j
}

function neo4j_stop {
	docker rm -f neo4j || true
}

function neo4j_dump_on_local {
    if [ $# -lt 1 ]; then
        echo -e USAGE: neo4j_dump_on_local ip
        return
    fi

    local IP=${1}

    ssh ${IP} 'rm -f graph.tar.gz'
    ssh ${IP} 'cd /data/neo4j/ && tar cvfpz ~/graph.tar.gz graph.db'

    neo4j_stop

    sudo rm -rf ~/applications/neo4j/data

    scp ${IP}:~/graph.tar.gz /tmp

    mkdir -p ~/applications/neo4j/data/databases
    tar xvzf /tmp/graph.tar.gz -C ~/applications/neo4j/data/databases

    neo4j_start
}

function neo4j_dump_itg_on_local {
    neo4j_dump_on_local "louser@172.17.10.81"
}

function neo4j_dump_nightly_on_local {
    neo4j_dump_on_local "louser@172.17.10.215"
}

function neo4j_purge {
    neo4j_stop
    sudo rm -rf ~/applications/neo4j/data
    mkdir -p ~/applications/neo4j/data
    neo4j_start
}

function neo4j_stash {
    neo4j_stop
    tar cvfpz /tmp/graph.db_stash.tar.gz -C ~/applications/neo4j/data/ graph.db
    neo4j_start
}

function neo4j_stash_pop {
    neo4j_stop
    sudo rm -rf ~/applications/neo4j/data/graph.db
    sudo tar xvfz /tmp/graph.db_stash.tar.gz -C ~/applications/neo4j/data/
    neo4j_start
}

function neo4j_delete_last_version {
    if [ $# -lt 1 ]; then
        echo -e "USAGE: neo4j_delete_last_version host[:port]"
        return
    fi
    NEO4J_HOST=$(echo $1  | awk -F":" '{print $1}')
    NEO4J_PORT=$(echo $1  | awk -F":" '{print $2}')
    if [ -z ${NEO4J_PORT} ]; then NEO4J_PORT=7474; fi

    queryJson='{
      "statements": [
        {
          "statement": "MATCH (v:Version) WITH v ORDER BY str(v.createdAt) WITH last(collect(v)) as vLast WITH vLast, vLast.name as name DELETE vLast RETURN name",
          "resultDataContents": [
            "row",
            "graph"
          ],
          "includeStats": true
        }
      ]
    }'

    curl -s \
      -H "Content-Type: application/json;charset=utf-8" -X POST -d "${queryJson}" "http://${NEO4J_HOST}:${NEO4J_PORT}/db/data/transaction/commit" \
      | jq -r '.results[0].stats.nodes_deleted as $deleted | .results[].data[].row[] as $version | if $deleted > 0 then "\($version) deleted !" else "no version found" end'
}

#################################
############# MYSQL #############
#################################

function mysql_start {
    mkdir -p ~/applications/mysql/data
    docker run -d --name mysql \
        -e MYSQL_ROOT_PASSWORD=root \
        -p 3306:3306 \
        -v ~/applications/mysql/data:/data \
        mysql:5.6 || docker start mysql
}

function mysql_stop {
	docker rm -f mysql || true
}

function _mysql_dump_on_local {
    if [ $# -lt 2 ]; then
        echo -e USAGE: _mysql_dump_on_local HOST DATABASE
        return
    fi
    local HOST=${1}
    local DATABASE=${2}
    local path_for_dump=/tmp/dump_itg_${DATABASE}.sql
    docker exec -i mysql mysqldump -h ${HOST} -u longback -plongback --databases ${DATABASE} > ${path_for_dump}
    docker exec -i mysql mysql -h localhost -uroot -proot < ${path_for_dump}
}

function mysql_dump_itg_on_local {
    _mysql_dump_on_local 172.17.10.81 $*
}

function _mysql_dump_on_local_all {
    local HOST=${1}
    local PATH_FOR_DUMP=${2}
    docker exec -i mysql mysqldump -h${HOST} -ulongback -plongback --databases `docker exec mysql mysql -h${HOST} -ulongback -plongback --skip-column-names -e "SELECT GROUP_CONCAT(schema_name SEPARATOR ' ') FROM information_schema.schemata WHERE schema_name NOT IN ('mysql','performance_schema','information_schema');"` > ${PATH_FOR_DUMP}
    docker exec -i mysql mysql -h localhost -uroot -proot < ${PATH_FOR_DUMP}
}

function mysql_dump_itg_on_local_all {
    _mysql_dump_on_local_all 172.17.10.81 /tmp/dump_itg.sql
}

function mysql_dump_prp_on_local_all {
    _mysql_dump_on_local_all 172.17.10.83 /tmp/dump_prp.sql
}

function mysql_dump_prod_on_local_all {
    _mysql_dump_on_local_all 172.17.10.84 /tmp/dump_prod.sql
}


#################################
############# MISC #############
#################################

function debug {
    set -x && $* && set +x
}

function untilfailure {
    i=0
    RETURN_VALUE=0
    while [ ${RETURN_VALUE} -eq 0 ];
    do
        eval ${1}
        RETURN_VALUE=$?
        echo "Try again $i"
        sleep 1
        i=$(($i + 1))
    done
    echo "Tried $i time(s)"
}

#############
# LA wisdom #
#############

function install-wisdom-if-necessary {
    WISDOM_DEV_SERVER=~/workspace/longback/wisdom-dev-server
    if [ ! -d "${WISDOM_DEV_SERVER}" ]; then
        echo "Installing Wisdom Dev Server..."
        cd ~/workspace/longback/
        git clone git@git.livingobjects.com:java/wisdom-dev-server.git
        cd wisdom-dev-server && git checkout develop && mvn clean package
    fi
}

function wisdom-run {
    WISDOM_DEV_SERVER=~/workspace/longback/wisdom-dev-server
    install-wisdom-if-necessary
    ${WISDOM_DEV_SERVER}/target/wisdom/run.sh "$@"
}

function wisdom-dev-update {
    if [ $# -lt 1 ]; then
        echo -e USAGE: wisdom-dev-update PROJECTS...
        return
    fi

    WISDOM_DEV_SERVER=~/workspace/longback/wisdom-dev-server
    DST=${WISDOM_DEV_SERVER}/target/wisdom/application
    CONF_DST=${WISDOM_DEV_SERVER}/target/wisdom/conf

    install-wisdom-if-necessary
    # rebuild if necessary
    if [ ! -d "${DST}" ]; then
         echo "Rebuilding wisdom-dev-server..."
         mvn package -f ${WISDOM_DEV_SERVER}/pom.xml
    fi

    for proj in $@; do
       baseappdir="${HOME}/workspace/longback/${proj}/${proj}-longd-application"
       appdir="${baseappdir}/target/longd-app"
       if [ ! -d "${baseappdir}" ]; then
           echo "longd-app not found at ${appdir}, trying the old way..."
           baseappdir="${HOME}/workspace/longback/${proj}/${proj}-wisdom-application"
           appdir="${baseappdir}/target/wisdom+${proj}/application"
       fi
       if [ ! -d "${appdir}" ]; then
           echo "Cannot deploy ${proj}, it is not built (tried with ${appdir})"
       else
           echo "Copying bundles from ${proj} to wisdom-dev-server..."
           echo "${appdir}/*.jar"
           mkdir -p ${DST}/${proj}
           cp -u ${appdir}/*.jar ${DST}/${proj}
           cp -ru ~/workspace/deploy/docker-deploy/${proj}/local_configuration/* ${CONF_DST}/
       fi
    done
    echo "Done."
    # TODO check if service and client of same service is there.
}

function mvnwatch {
    if [ "$#" -eq 0 ]; then
        WISDOM_DEV_SERVER=~/workspace/longback/wisdom-dev-server
        ASSDIR=${WISDOM_DEV_SERVER}/target/wisdom/application/${PWD##*/}
    else
        local ASSDIR=$1
    fi
    echo $ASSDIR
    # Update project
    wisdom-dev-update ${PWD##*/}

    # Watch
    mvn io.lambdacube.maven:watch-maven-plugin:1.2:watch -DrefreshURL='http://localhost:9100/osgi/refresh/?b=' -DdestDirectory="${ASSDIR}"
}

function mvnwatch_skipTests {
    if [ "$#" -eq 0 ]; then
        WISDOM_DEV_SERVER=~/workspace/longback/wisdom-dev-server
        ASSDIR=${WISDOM_DEV_SERVER}/target/wisdom/application/${PWD##*/}
    else
        local ASSDIR=$1
    fi
    echo $ASSDIR
    # Update project
    wisdom-dev-update ${PWD##*/}

    # Watch
    mvn io.lambdacube.maven:watch-maven-plugin:1.2:watch -DrefreshURL='http://localhost:9100/osgi/refresh/?b=' -DdestDirectory="${ASSDIR}" -DskipTests
}

function mvnwatch_all {
    if [ "$#" -eq 0 ]; then
        WISDOM_DEV_SERVER=~/workspace/longback/wisdom-dev-server
        ASSDIR=${WISDOM_DEV_SERVER}/target/wisdom/application/${PWD##*/}
    else
        local ASSDIR=$1
    fi
    echo $ASSDIR
    # Update project
    wisdom-dev-update_all ${PWD}

    # Watch
    mvn io.lambdacube.maven:watch-maven-plugin:1.2:watch -DrefreshURL='http://localhost:9100/osgi/refresh/?b=' -DdestDirectory="${ASSDIR}"
}


function wisdom-dev-update_all {
    if [ $# -lt 1 ]; then
        echo -e USAGE: wisdom-dev-update LONGD-APPLICATION-PATH
        return
    fi

    WISDOM_DEV_SERVER=~/workspace/longback/wisdom-dev-server
    DST=${WISDOM_DEV_SERVER}/target/wisdom/application
    CONF_DST=${WISDOM_DEV_SERVER}/target/wisdom/conf

    APP_DIR=${1}
    PROJ=${APP_DIR##*/}
    install-wisdom-if-necessary
    # rebuild if necessary
    if [ ! -d "${DST}" ]; then
         echo "Rebuilding wisdom-dev-server..."
         mvn package -f ${WISDOM_DEV_SERVER}/pom.xml
    fi

    appdir="${APP_DIR}/target/longd-app"

    if [ ! -d "${appdir}" ]; then
       echo "Cannot deploy ${PROJ}, it is not built (tried with ${appdir})"
    else
       echo "Copying bundles from ${PROJ} to wisdom-dev-server..."
       echo "${appdir}/*.jar"
       mkdir -p ${DST}/${PROJ}
       cp -u ${appdir}/*.jar ${DST}/${PROJ}
       cp -ru ~/workspace/deploy/docker-deploy/${PROJ:0:-18}/local_configuration/* ${CONF_DST}/
    fi
    echo "Done."
    # TODO check if service and client of same service is there.
}

############
# LA token #
############

function _doormanToken {
    if [[ $# -lt 3 ]] || [[ $# -gt 3 ]]; then
        echo -e USAGE: _doormanToken ip username password
        return
    fi
    local ip=${1}
    local username=${2}
    local password=${3}
    token=`curl --silent --header 'Content-Type: application/json' --request POST --data '{"username":"'"${username}"'","password":"'"${password}"'"}' http://${ip}/auth/internal/login | jq -r '.userToken'`
    echo "X-UserToken:${token}"
}

function doormanToken {
    doormanTokenItg
}

function doormanTokenItg {
   _doormanToken turbot/service/bach admin admin
}

function doormanTokenTanche {
   _doormanToken tanche/service/bach admin admin
}

function doormanTokenNightly {
   _doormanToken 172.17.10.215/service back admin
}

function doormanTokenLocal {
   _doormanToken localhost:9100 back admin
}

function doormanTokenPrp {
   _doormanToken 172.17.10.83/service back admin
}

function doormanTokenProd {
   _doormanToken 172.17.10.84/service back admin
}

function doormanTokenResilience1 {
   _doormanToken 172.17.10.134/service back admin
}

function doormanTokenResilience2 {
   _doormanToken 172.17.10.135/service back admin
}

function deploy-multiple-extra-jar {
    if [[ $# -lt 2 ]]; then
        echo "Usage : deploy-multiple-extra-jar <remote_platform> <container> [<jarFile> ...] "
        return 1
    fi

    remote_platform=${1}
    container=${2}
    shift
    shift
    for jar in "$@"
    do
        deploy-extra-jar $jar $remote_platform $container
    done
}

alias deploy_integration='deploy lo-itg'
alias jenkins_release='java -jar ~/applications/jenkins-cli.jar -s http://172.17.10.81:8080/ build `basename ${PWD}-RELEASE` -s'
function tkillws {
    for i in $(eval echo {$1..$2});
    do
        echo "kill $i";
        tmux kill-window -t ${i};
    done
}

function replace-pom-properties-all () {
    if [ $# -lt 1 ]; then
        echo -e USAGE:   replace-pom-properties-all PROPERTY=VALUE...
        echo -e EXAMPLE: replace-pom-properties-all longback-bom.version=1.0 longback-runtime.version=1.0
        return;
    fi;

    local properties=$@

    for p in ${LO_JAVA_PROJECTS} ; do
        local current_dir=~/workspace/${p}
        echo "${current_dir}"
        replace-pom-properties ${current_dir} ${properties} || return 1
    done;
}

function replace-pom-properties {
    if [ $# -lt 2 ]; then
        echo -e USAGE:   replace-pom-properties PATH PROPERTY=VALUE...
        echo -e EXAMPLE: replace-pom-properties ~/workspace/longback/cosmos longback-bom.version=1.0 longback-runtime.version=1.0
        return;
    fi;

    local dir=${1}
    local property=${@:2}

    if [ ! -d "${dir}" ]; then
        echo -e "ERROR: ${dir} doesn't exist"
        return 1;
    fi

    for i in ${property} ; do
        local key=${i%=*};
        local value=${i#*=};
        find ${dir} -name "pom.xml" -type f -print | xargs sed -i -e "s|<${key}>[0-9a-zA-Z._\-]\{1,\}</${key}>|<${key}>${value}</${key}>|g"
    done;
}

function dockerscp-jar {
    if [[ $# -lt 4 ]]; then
        echo "Usage : destination(eg: itg_perf) project(eg:cosmos) module(eg:client) dst_module(eg:backeyelov3-light)"
        return 1
    fi

    dst=${1}
    project=${2}
    module=${3}
    dst_module=${4}

    cd ~/workspace/longback/$project;
    mvn clean install -DskipTests;
    jar=$(ls $project-$module/target |grep -v sources|grep jar);
    scp $project-$module/target/$jar $dst:;
    docker=$(ssh $dst 'docker ps'|grep "$dst_module"| awk '{print $1}');
    echo $docker
    echo docker cp $jar $docker:/services/longback-daemon/application/$dst_module
    ssh $dst "docker cp $jar $docker:/services/longback-daemon/application/$dst_module";
}

function dockerscp {
    if [[ $# -lt 3 ]]; then
        echo "Usage : file dst(eg:itg_perf) docker(eg:backeyelov3-light)"
        return 1
    fi

    file=${1}
    dst=${2}
    docker=${3}

    fileName=$(basename $file)
    echo $fileName

    scp $file $dst:;
    ssh $dst "docker cp $fileName $docker:/services/longback-daemon/application";
    ssh $dst "rm $fileName";
}

function longback-un-hotfix-finish {
    if [[ $# -lt 1 ]]; then
        echo "Usage : version (4.6.2)"
        return 1
    fi

    version=${1}
    if [ !`git branch --list hotfix/${version}` ]
    then
        echo branch hotfix/${version} does not exist
        return 1
    fi


    git co master && \
    git merge --no-edit hotfix/${version} && \
    git push && \
    git tag ${version} && \
    git push origin ${version}
    mvn clean deploy && \
    git co develop && \
    git pull && \
    git merge master --no-edit --strategy-option ours && \
    git push && \
    git branch -d hotfix/${version} && \

    if [ `git branch -r --list origin/hotfix/${version}` ]
    then
        git push origin :hotfix/${version};
    fi

}

function deploy-extra-jar {
    if [[ $# -lt 1 ]]; then
        echo "Usage : deploy-extra-jar <jarFile> [<remote_platform>] [<container>]"
        echo "By default deploy on turbot bach container"
        return 1
    fi

    jarFile=${1}
    remote_platform=${2:-turbot}
    container=${3:-bach}

    echo "scp ${jarFile} ${remote_platform}:/data/jar/${container}"
    scp ${jarFile} ${remote_platform}:/data/jar/${container}
}

function clear-extra-jars {
    remote_platform=${1:-turbot}
    container=${2:-bach}

    echo "ssh ${remote_platform} rm /data/jar/${container}/*.jar"
    ssh ${remote_platform} rm /data/jar/${container}/*.jar
}

#################################
########### FARCASTER ###########
#################################

function farcaster_dump_itg_on_local {
    if [[ $# -lt 1 ]] || [[ $# -gt 1 ]]; then
        echo -e USAGE: farcaster_dump_itg_on_local date
        ssh farcaster@172.17.11.111 "ls /data/memdex/iwan/client-1/interface/5minutes/"
        return
    fi
    ssh farcaster@172.17.11.111 "cd /data/memdex && nice tar cvzpf - iwan/client-1/interface/5minutes/$1" | nice tar xzpf - -C /tmp/farcaster
}

#################################
########### TETHYS ###########
#################################
function _tethys-send {
  if [[ $# -lt 2 ]] || [[ $# -gt 3 ]] ; then
    echo 'Usage:   _tethys-send host[:port] TOPIC [FILE]'
    echo
    echo 'Example: _tethys-send 172.17.11.20:9000 /bus/my-event /path/to/my/event/content.json'
    echo 'Example: _tethys-send 172.17.11.20:9000 /bus/my-event <(echo '{"name": "John","email": "john@example.org"}')'
    echo 'Example: _tethys-send 172.17.11.20:9000 /bus/my-event <(echo '"customer:1"')'
    echo
    return;
  fi

  TETHYS_URL=$1
  TOPIC=$2
  NOW=`date +'%s'`
  NOW_FORMATTED=`date -u +"%Y-%m-%dT%H:%M:%SZ" --date="@${NOW}"`
  UUID=$(cat /proc/sys/kernel/random/uuid)
  MESSAGE=null

  if [[ $# -eq 3 ]] ; then
    MESSAGE=$(cat $3)
  fi

  JSON="{\"topic\":\"$TOPIC\",\"timeSent\":\"$NOW_FORMATTED\",\"from\":{\"serviceName\":\"tethys-test\",\"serviceInstanceId\":0},\"uuid\":\"$UUID\",\"message\":${MESSAGE}}"

  curl -H "Content-Type: application/json" -X POST -d "${JSON}" "$TETHYS_URL/bus/event"
}

function tethys-send-local {
  _tethys-send http://localhost:9100 $1 $2
}

function tethys-send-itg {
  _tethys-send http://172.17.10.81:9013 $1 $2
}

function _memdex-check {
    url=${1}
    health=`http ${url}/service/heartbeat/path/collect%2Fcount`
    recentCount=`echo ${health} |grep -oP "Recent memdex count : (\d*)" |awk -F" " '{print $5}'`
    if [[ -z "$recentCount" ]]; then
        recentCount="0"
    fi
    warningCount=`echo ${health} |grep -oP "Warning memdex count : (\d*)" |awk -F" " '{print $5}'`
    if [[ -z "$warningCount" ]]; then
        warningCount="0"
    fi
    echo ${recentCount}/${warningCount}
}

function memdex-check-sfr {
    _memdex-check www.perfsapp.sfrbusiness.fr
}



