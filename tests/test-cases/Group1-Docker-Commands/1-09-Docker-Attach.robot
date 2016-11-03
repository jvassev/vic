*** Settings ***
Documentation  Test 1-09 - Docker Attach
Resource  ../../resources/Util.robot
Suite Setup  Install VIC Appliance To Test Server
Suite Teardown  Cleanup VIC Appliance On Test Server

*** Test Cases ***
Basic attach
    ${out}=  Run  docker ${params} pull busybox
    #${rc}  ${containerID}=  Run And Return Rc And Output  docker ${params} create -it busybox /bin/top
    #Should Be Equal As Integers  ${rc}  0
    #${rc}  ${out}=  Run And Return Rc And Output  docker ${params} start ${containerID}
    #Should Be Equal As Integers  ${rc}  0
    #${rc}  ${out}=  Run And Return Rc And Output  docker ${params} attach ${containerID}
    #Should Be Equal As Integers  ${rc}  0
    
    
    #3. Issue docker start <containerID> to the VIC appliance
    #4. Issue docker attach <containerID> to the VIC appliance
    #5. Issue ctrl-p then ctrl-q to the container

Attach to stopped container
    ${out}=  Run  docker ${params} pull busybox
    ${rc}  ${out}=  Run And Return Rc And Output  docker ${params} create -it busybox /bin/top
    Should Be Equal As Integers  ${rc}  0
    ${rc}  ${out}=  Run And Return Rc And Output  docker ${params} attach ${out}
    Should Be Equal As Integers  ${rc}  1
    Should Be Equal  ${out}  You cannot attach to a stopped container, start it first

Attach with custom detach keys
    ${rc}  ${output}=  Run And Return Rc And Output  mkfifo /tmp/fifo
    ${out}=  Run  docker ${params} pull busybox
    ${rc}  ${containerID}=  Run And Return Rc And Output  docker ${params} create -it busybox /bin/top
    Should Be Equal As Integers  ${rc}  0
    ${rc}  ${out}=  Run And Return Rc And Output  docker ${params} start ${containerID}
    Should Be Equal As Integers  ${rc}  0
    Start Process  screen sh -c "docker attach --detach-keys\=a ${containerID} < /tmp/fifo"  shell=True  alias=custom
    Sleep  5
    Run  echo a > /tmp/fifo
    ${ret}=  Wait For Process  custom
    Log  ${ret.stdout}
    Log  ${ret.stderr}

Reattach to container
    Log To Console  todo
    #2. Issue docker create -it busybox /bin/top to the VIC appliance
    #3. Issue docker start <containerID> to the VIC appliance
    #4. Issue docker attach <containerID> to the VIC appliance
    #5. Issue ctrl-p then ctrl-q to the container
    #4. Issue docker attach <containerID> to the VIC appliance

Attach to fake container
    ${rc}  ${out}=  Run And Return Rc And Output  docker ${params} attach fakeContainer
    Should Be Equal As Integers  ${rc}  1
    Should Contain  ${out}  Error: No such container: fakeContainer