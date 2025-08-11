export PATH="$HOME/.local/bin:$PATH"
source sites.env

PROJECT=uc26


RESULT=""

# set path to skupper and oc cli
#alias skupper=/home/vscode/.local/bin/skupper
#alias oc=/usr/local/bin/oc

# install skupper cli
# curl https://skupper.io/install.sh | sh
# export PATH="$HOME/.local/bin:$PATH"

declare menu_array
declare status_array

menu_array["1"]="  1) init"
menu_array["2"]="  2) init"
menu_array["3"]="  3) init"
menu_array["4"]="  4) bind service"
menu_array["5"]="  5) bind service"
menu_array["6"]="  6) bind service"
menu_array["7"]="  7) unbind service"
menu_array["8"]="  8) unbind service"
menu_array["9"]="  9) unbind service"

status_array["1"]="❌"
status_array["2"]="❌"
status_array["3"]="❌"

# Function to check if an array contains an item
highlight() {
  return "\033[43m$1\033[0m"
}


# https://patorjk.com/software/taag/#p=testall&f=Flipped&t=resilience%20testing


menu (){
sleep 1s
clear
echo "                         ┏   ┏┓        ┓┏  ┓   • ┓  ┏┓┓     ┓   ┓"
echo "           _\|/_        ━┫   ┃┃┏┓┏┓┏┓  ┣┫┓┏┣┓┏┓┓┏┫  ┃ ┃┏┓┓┏┏┫   ┣━"
echo "           (o o)         ┗   ┗┛┣┛┗ ┛┗  ┛┗┗┫┗┛┛ ┗┗┻  ┗┛┗┗┛┗┻┗┻   ┛"
echo " ┏━━━━━━oOO.{-}.OOo━━━━━━━┳━━━━┛━━━━━━━━━━┛━━━━━━━━━━━━━━━━━━━━━━━━[ Demo ]━━┓"
echo " ┃  ╦═╗╔═╗╔╦╗  ╦ ╦╔═╗╔╦╗  ┃  ┬─┐┌─┐┌─┐┬┬  ┬┌─┐┌┐┌┌─┐┌─┐  ┌┬┐┌─┐┌─┐┌┬┐┬┌┐┌┌─┐ ┃"
echo " ┃  ╠╦╝║╣  ║║  ╠═╣╠═╣ ║   ┃  ├┬┘├┤ └─┐││  │├┤ ││││  ├┤    │ ├┤ └─┐ │ │││││ ┬ ┃"
echo " ┃  ╩╚═╚═╝═╩╝  ╩ ╩╩ ╩ ╩   ┃  ┴└─└─┘└─┘┴┴─┘┴└─┘┘└┘└─┘└─┘   ┴ └─┘└─┘ ┴ ┴┘└┘└─┘ ┃"
echo " ┣━━━━━━━━━━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━━━━┫"
echo " ┃  ┳┓┏┓                  ┃  ┏┓┓ ┏┏┓                ┃  ┏┓┏┓┳┳┳┓┏┓            ┃"
echo " ┃  ┃┃┃     ${status_array["1"]}            ┃  ┣┫┃┃┃┗┓       ${status_array["2"]}       ┃  ┣┫┏┛┃┃┣┫┣      ${status_array["3"]}     ┃"
echo " ┃  ┻┛┗┛                  ┃  ┛┗┗┻┛┗┛                ┃  ┛┗┗┛┗┛┛┗┗┛            ┃"
echo " ┣━━━━━━━━━━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━━━━━━━━━━━┫"
echo " ┃ ${menu_array[1]}              ┃ ${menu_array[2]}               ┃ ${menu_array[3]}              ┃"
echo " ┃ ${menu_array[4]}      ┃ ${menu_array[5]}       ┃ ${menu_array[6]}      ┃"
echo " ┃ ${menu_array[7]}    ┃ ${menu_array[8]}     ┃ ${menu_array[9]}    ┃"
echo " ┣━━━━━━━━━━━━━━━━━━━━━━━━┻━━━━━━━━━━━━━━━━━━━━━━━━━┻━━━━━━━━━━━━━━━━━━━━━━━━┫"
echo " ┃  [l] Link All        [e] Expose services          [d] Delete all          ┃"
echo " ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
echo " $RESULT "

}

menu

while true
do
MSG=""
read n
case $n in

"1")
# DC
if [[ $DC_STATUS == "on" ]] 
then
  oc login --server=$DC_URL -u $DC_UID -p $DC_PWD --insecure-skip-tls-verify=true
  if ! oc get project $PROJECT > /dev/null 2>&1; then
      oc new-project $PROJECT
    else
      oc project $PROJECT
      echo "Project $PROJECT already exists"
  fi
  skupper init --enable-console --enable-flow-collector --console-auth unsecured --site-name dc-site
  skupper token create aws_to_dc.token
  skupper token create azure_to_dc.token
  skupper token create azure_native_to_dc.token
  menu_array["1"]="✅1) init"
  status_array["1"]="✅"
fi  
;;

"2")
#AWS
if [[ $AWS_STATUS == "on" ]] 
then
  oc login --server=$AWS_URL -u $AWS_UID -p $AWS_PWD --insecure-skip-tls-verify=true
  if ! oc get project $PROJECT > /dev/null 2>&1; then
      oc new-project $PROJECT
    else
      oc project $PROJECT
      echo "Project $PROJECT already exists"
  fi
  skupper init --enable-console --enable-flow-collector --console-auth unsecured --site-name aws-site
  menu_array["2"]="✅2) init"
  status_array["2"]="✅"
fi
;;

"3")
#AZURE
if [[ $AZURE_STATUS == "on" ]] 
then
  oc login --server=$AZURE_URL -u $AZURE_UID -p $AZURE_PWD --insecure-skip-tls-verify=true
  if ! oc get project $PROJECT > /dev/null 2>&1; then
      oc new-project $PROJECT
    else
      oc project $PROJECT
      echo "Project $PROJECT already exists"
  fi
  skupper init --enable-console --enable-flow-collector --console-auth unsecured --site-name azure-site
  menu_array["3"]="✅3) init"
  status_array["3"]="✅"
fi
;;

"4")
# bind service on DC
oc login --server=$DC_URL -u $DC_UID -p $DC_PWD --insecure-skip-tls-verify=true
oc project $PROJECT
skupper service bind mysql service mysqldb
menu_array["4"]="✅4) bind service"
menu_array["7"]="  7) unbind service"
;;

"5")
# bind service on AWS
oc login --server=$AWS_URL -u $AWS_UID -p $AWS_PWD --insecure-skip-tls-verify=true
oc project $PROJECT
#skupper service bind rtgs-apis service rtgs-apis-rhsi
skupper service bind mysql service mysqldb
menu_array["5"]="✅5) bind service"
menu_array["8"]="  8) unbind service"
;;


"6")
# bind service on AWS
oc login --server=$AZURE_URL -u $AZURE_UID -p $AZURE_PWD --insecure-skip-tls-verify=true
oc project $PROJECT
skupper service bind mysql service mysqldb
menu_array["6"]="✅6) bind service\033[0m"
menu_array["9"]="  9) unbind service"
;;




"7")
# DC unbind
# unbind the service in DC to see the impact
oc login --server=$DC_URL -u $DC_UID -p $DC_PWD --insecure-skip-tls-verify=true
oc project $PROJECT
skupper service unbind mysql service mysqldb
menu_array["7"]="✅7) unbind service"
menu_array["4"]="  4) bind service"
;;

"8")
# unbind service on AWS
oc login --server=$AWS_URL -u $AWS_UID -p $AWS_PWD --insecure-skip-tls-verify=true
oc project $PROJECT
skupper service unbind mysql service mysqldb
menu_array["8"]="✅8) unbind service"
menu_array["5"]="  5) bind service"
;;

"9")
# unbind service on Azure
oc login --server=$AZURE_URL -u $AZURE_UID -p $AZURE_PWD --insecure-skip-tls-verify=true
oc project $PROJECT
skupper service unbind mysql service mysqldb
menu_array["9"]="✅9) unbind service"
menu_array["6"]="  6) bind service"
;;



"l")
# Link All
if [[ $AWS_STATUS == "on" ]] 
then
  echo "---- AWS ----"
  oc login --server=$AWS_URL -u $AWS_UID -p $AWS_PWD --insecure-skip-tls-verify=true
  oc project $PROJECT
  skupper link create aws_to_dc.token --name aws-to-dc
fi

if [[ $AZURE_STATUS == "on" ]] 
then
  echo "---- AZURE ----"
  oc login --server=$AZURE_URL -u $AZURE_UID -p $AZURE_PWD --insecure-skip-tls-verify=true
  oc project $PROJECT
  skupper link create azure_to_dc.token --name azure-to-dc
fi

;;


"e")
# DC : Expose db service
# Make sure you remove local svc for postgresql and rtgs-apis
oc login --server=$DC_URL -u $DC_UID -p $DC_PWD --insecure-skip-tls-verify=true
oc project $PROJECT
skupper service create postgresql 5432 --protocol tcp
#skupper service create rtgs-apis 8080 --protocol http
;;

"d")
if [[ $DC_STATUS == "on" ]] 
then
  oc login --server=$DC_URL -u $DC_UID -p $DC_PWD --insecure-skip-tls-verify=true
  oc project $PROJECT
  skupper delete
fi

if [[ $AWS_STATUS == "on" ]] 
then
  oc login --server=$AWS_URL -u $AWS_UID -p $AWS_PWD --insecure-skip-tls-verify=true
  oc project $PROJECT
  skupper delete
fi

if [[ $AZURE_STATUS == "on" ]] 
then
  oc login --server=$AZURE_URL -u $AZURE_UID -p $AZURE_PWD --insecure-skip-tls-verify=true
  oc project $PROJECT
  skupper delete
fi

;;



"c1")
MSG="[c1] Business continuity policies and disaster recovery plans as a C-level responsibility"
;;
"c2")
MSG="[c2] Harmonization of mandatory incident reporting frameworks (e.g. GDPR, NIS, eIDAs, SSM, PSD2)"
;;
"c3")
MSG="[c3] At least annually, including remediation plans with ICT third party providers direct involvement"
;;
"c4")
MSG="[c4] Critical ICT Third-Parties subject to an EU oversight framework under a financial European Supervisory Authority"
;;
"c5")
MSG="[c5] Voluntary exchange of threat information & Intelligence are allowed and supported"
;;

esac

RESULT="Step [$n] is done"
menu "done" $n

done
