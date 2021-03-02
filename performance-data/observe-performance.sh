LOGFILE="acm-agent-observability-agent.txt"
NODE="worker-1.clus3a.t5g.lab.eng.bos.redhat.com"
oc get node >> "${LOGFILE}"
oc describe node "${NODE}"  | egrep -A5 "Capacity|Resource" >> "${LOGFILE}"
date >> "${LOGFILE}"
while sleep 30; do oc adm top pod -n  open-cluster-management-agent >> "${LOGFILE}" && oc adm top pod -n  open-cluster-management-agent-addon >> "${LOGFILE}" && oc adm top pod -n open-cluster-management-addon-observability >> "${LOGFILE}";done
