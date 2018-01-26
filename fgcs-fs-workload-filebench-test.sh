#!/bin/bash
# Description: running oltp in pmfs/nova for multiple times and get the page counter of each page
#
#  Author: wujing(wulin_cqu@cqu.edu.cn)
#
#  Revision History:
#       2018/1/7 initial version

total_run_times=100

pmfs_setup_directory="/home/wujing/work/hdd/linux-work/fgcs-exp/pmfs"
nova_setup_directory="/home/wujing/work/hdd/linux-work/fgcs-exp/nova"

test_pmfs_filebench()
{
	#cd $pmfs_setup_directory
	#./setup-pmfs.sh
	#for ((test_times = 0;test_times < $total_run_times;test_times++))
	#do
	#	echo "PMFS Fileserver, Current test_times:$test_times"
	#	filebench -f /home/wujing/work/hdd/linux-work/fgcs-exp/workloads/fileserver-pmfs.f
	#	sed 1,2d /proc/pmfs_page_counter > /dev/shm/pmfs-fileserver-$test_times
	#done

	#cd $pmfs_setup_directory
	#./setup-pmfs.sh
	for ((test_times = 0;test_times < $total_run_times;test_times++))
	do
		echo "PMFS varmail, Current test_times:$test_times"
		filebench -f /home/wujing/work/hdd/linux-work/fgcs-exp/workloads/varmail-pmfs.f
		sed 1,2d /proc/pmfs_page_counter > /dev/shm/pmfs-varmail-$test_times
	done
}



test_nova_filebench()
{
	#cd $nova_setup_directory
	#./setup-nova.sh
	#for ((test_times = 0;test_times < $total_run_times;test_times++))
	#do
	#	echo "NOVA Fileserver, Current test_times:$test_times"
	#	filebench -f /home/wujing/work/hdd/linux-work/fgcs-exp/workloads/fileserver-nova.f
	#	sed 1,2d /proc/nova_page_counter > /dev/shm/nova-fileserver-$test_times
	#done

	#cd $nova_setup_directory
	#./setup-nova.sh
	for ((test_times = 0;test_times < $total_run_times;test_times++))
	do
		echo "NOVA varmail, Current test_times:$test_times"
		filebench -f /home/wujing/work/hdd/linux-work/fgcs-exp/workloads/varmail-nova.f
		sed 1,2d /proc/nova_page_counter > /dev/shm/nova-varmail-$test_times
	done
}

test_simfs_filebench()
{
	for ((test_times = 0;test_times < $total_run_times;test_times++))
	do
		echo "SIMFS fileserver, Current test_times:$test_times"
		filebench -f /home/wujing/work/hdd/linux-work/fgcs-exp/workloads/fileserver-simfs.f
		cat /proc/simfs_page_counter_no_wl > /dev/shm/simfs-fileserver-$test_times
	done
}

#test_pmfs_filebench &
#test_nova_filebench

test_simfs_filebench
