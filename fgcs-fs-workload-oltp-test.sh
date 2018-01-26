#!/bin/bash
# Description: running oltp in pmfs/nova for multiple times and get the page counter of each page
#
#  Author: wujing(wulin_cqu@cqu.edu.cn)
#
#  Revision History:
#       2018/1/7 initial version

total_run_times=100

test_pmfs_oltp()
{
	for ((test_times = 0;test_times < $total_run_times;test_times++))
	do
		echo "Current test_times:$test_times"

		sysbench --test=oltp --oltp-table-size=7500000 --mysql-db=mysql --mysql-user=root --mysql-password=123 --mysql-port=3036 prepare
		sysbench --test=oltp --oltp-table-size=7500000 --mysql-db=mysql --mysql-user=root --mysql-password=123 --mysql-port=3036 cleanup
		sed 1,2d /proc/pmfs_page_counter > /dev/shm/pmfs-oltp-$test_times
	done
}



test_nova_oltp()
{
	for ((test_times = 0;test_times < $total_run_times;test_times++))
	do
		echo "Current test_times:$test_times"

		sysbench --test=oltp --oltp-table-size=7500000 --mysql-db=mysql --mysql-user=root --mysql-password=123 --mysql-port=3036 prepare
		sysbench --test=oltp --oltp-table-size=7500000 --mysql-db=mysql --mysql-user=root --mysql-password=123 --mysql-port=3036 cleanup
		sed 1,2d /proc/nova_page_counter > /dev/shm/nova-oltp-$test_times
	done
}

#test_pmfs_oltp
test_nova_oltp