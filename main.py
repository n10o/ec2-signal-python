from os import chdir
from os.path import dirname, abspath
from boto.ec2 import connect_to_region as ec2conn
from boto.ec2.elb import connect_to_region as elbconn
from bottle import route, run, default_app, template, redirect, request, url, static_file
import ConfigParser

RUN = "running"
STOP = "stopped"

config = ConfigParser.SafeConfigParser()
config.read(abspath(dirname(__file__)) + "/config.ini")
ACCESSKEY = config.get("key", "accesskey")
SECRETKEY = config.get("key", "secretkey")
CONFIGPATH = config.get("general", "configpath")
REGION = config.get("general", "region")

@route('/')
def main():
    instanceIds = []
    instanceNames = []
    instanceStates = []
    with open(CONFIGPATH, 'r') as config:
        for line in config.readlines():
            instanceId = line[:-1].split(',')[0].strip()
            conn = getEc2Connection()
            instance = getEc2Instance(conn, instanceId)
            instanceIds.append(instanceId)
            instanceNames.append(instance.tags.get("Name"))
            instanceStates.append(instance.state)
    return template('mainview', instanceName=instanceNames, instanceId=instanceIds, instanceState=instanceStates, URL=url('/'))

@route('/doStart')
def doStart():
    id = request.query['id']
    conn = getEc2Connection()
    instance = getEc2Instance(conn, id)
    if instance.state == STOP:
        conn.start_instances(id)
    with open(CONFIGPATH, 'r') as config:
        for line in config.readlines():
            elbname = line[:-1].split(',')
            if elbname[0].strip() == id and len(elbname) == 2:
                reregisterElb(elbname[1].strip(), id)
    redirect(url('/'))

@route('/doStop')
def doStop():
    id = request.query['id']
    conn = getEc2Connection()
    instance = getEc2Instance(conn, id)
    if instance.state == RUN:
        conn.stop_instances(id)
    redirect(url('/'))

@route('/redirectIndex')
def redirectIndex():
    redirect(url('/'))

@route('/static/<filepath:path>')
def static(filepath):
    return static_file(filepath, root="./static")

def getEc2Connection():
    return ec2conn(REGION, aws_access_key_id=ACCESSKEY, aws_secret_access_key=SECRETKEY)

def getEc2Instance(conn, id):
    res = conn.get_all_instances(filters={'instance-id' : id})
    return res[0].instances[0]

def reregisterElb(elbName, instanceId):
    conn = elbconn(REGION, aws_access_key_id=ACCESSKEY, aws_secret_access_key=SECRETKEY)
    elb = conn.get_all_load_balancers(load_balancer_names=[elbName])
    elb[0].deregister_instances(instanceId)
    elb[0].register_instances(instanceId)

if __name__ == "__main__":
    run(host='localhost', port=8080, debug=True, reloader=True)
else:
    chdir(dirname(__file__))
    application = default_app()
