#!/bin/bash
#  Description: issue multiple fio test to the target filesystem
#
#  Author: wujing(wulin_cqu@cqu.edu.cn)
#
#  Revision History: 
#	Pre-2017:   The initial version to get iops/bw from multiple runs
#	2017/12/17: Gather the latency stattistics 
#	2017/12/18: Add the resultpath parameter
#	2018/01/12£º Add get_cpu_usage function to collect CPU% when running fio

usage()
{
echo -e "\n...USAGE ERROR!!!...\n"
echo -e "\nUsage:$(basename $0) testpath resultpath "
echo -e "\ne.g. ./fio_multi_process.sh /mnt/simfs /dev/shm/result \n\n"
exit 1
}


testpath=$1
resultpath=$2

(($# == 2)) || usage


#This function takes one parameter, the cpu_usage result file name
#The percentage is APPENDED to this file
get_cpu_usage()
{
	cpu_usage_result_file_name=$1
	ps -aux  | grep -w fio | grep -v "grep" | awk '{print $3}' | head -1 >> $cpu_usage_result_file_name
	sleep 1
}


fio_auto_test_multi_process()
{
	#test_mode=("read" "write" "randread" "randwrite")
	test_mode=("read" "write")
	mode_index="0"
	#test_block_size=("1k" "2k" "4K" "8K" "16K" "32K" "64K" "128K" "256K" "512K" "1M" "2M")
	test_block_size=( "1K" "4K" "256K" "2M") 
        #test_block_size=( "1K")
	#test_block_size=("2k")
	block_size_index="0"
	#num_jobs=("16")
	num_jobs=( "1")
	num_jobs_index="0"

	final_write_bw_file_name=bw-10-in-1-write
	final_read_bw_file_name=bw-10-in-1-read
	final_randread_bw_file_name=bw-10-in-1-randread
	final_randwrite_bw_file_name=bw-10-in-1-randwrite
	PWD=`pwd`
	if [[ ! -e $resultpath ]]; then
		echo "Result directory does not exist, creating it...\n"
		mkdir -p $resultpath
	fi
	cd $resultpath
	>$final_write_bw_file_name
	>$final_read_bw_file_name
	>$final_randread_bw_file_name
	>$final_randwrite_bw_file_name
	
	final_write_iops_file_name=iops-10-in-1-write
	final_read_iops_file_name=iops-10-in-1-read
	final_randread_iops_file_name=iops-10-in-1-randread
	final_randwrite_iops_file_name=iops-10-in-1-randwrite
	>$final_write_iops_file_name
	>$final_read_iops_file_name
	>$final_randread_iops_file_name
	>$final_randwrite_iops_file_name

	final_write_latency_file_name=latency-10-in-1-write
	final_read_latency_file_name=latency-10-in-1-read
	final_randread_latency_file_name=latency-10-in-1-randread
	final_randwrite_latency_file_name=latency-10-in-1-randwrite
	>$final_write_latency_file_name
	>$final_read_latency_file_name
	>$final_randread_latency_file_name
	>$final_randwrite_latency_file_name

	for ((test_times = 0;test_times < 1;test_times++))
	do
		for ((num_jobs_index = 0;num_jobs_index < ${#num_jobs[@]};num_jobs_index++))
		do
			for ((block_size_index = 0;block_size_index < ${#test_block_size[@]};block_size_index++))
			do
				for ((mode_index = 0;mode_index < ${#test_mode[@]};mode_index++))
				do
					data_file_name=fio`echo $testpath | sed 's/\//-/g'`-T${num_jobs[num_jobs_index]}-bs${test_block_size[block_size_index]}-${test_mode[mode_index]}-${test_times}
		    		echo $data_file_name

					#The file size should be twice as large as the system memory size
					size=16G


					fio -directory=$testpath -iodepth 1 -thread  -rw=${test_mode[mode_index]} -bs=${test_block_size[block_size_index]} -size=$size -numjobs=${num_jobs[num_jobs_index]} -name=mytest > $data_file_name
					rm -rf $testpath/*
					
					bw_file_name=bw`echo $testpath | sed 's/\//-/g'`-${test_mode[mode_index]}-${test_times}
					iops_file_name=iops`echo $testpath | sed 's/\//-/g'`-${test_mode[mode_index]}-${test_times}
					latency_file_name=latency`echo $testpath | sed 's/\//-/g'`-${test_mode[mode_index]}-${test_times}

					#get the total bandwidth value of the all the running processes
					cat $data_file_name | grep aggrb | awk -F"," '{print $2}' | sed 's/aggrb=//' >> $bw_file_name
					#get the average iops of all processes
					cat $data_file_name | grep iops | awk -F"," '{print $3}' | awk -F"=" '{print $2}' | awk '{total += $1;count++} END {print total}' >> $iops_file_name
					#get the average latency of all processes
					cat $data_file_name | grep -w lat | grep avg | awk -F"," '{print $3}' | awk -F"=" '{print $2}' | awk '{total += $1;count++} END {print total/count}' >> $latency_file_name
				done
			done
		done		
	done

	for ((test_times = 0;test_times < 1;test_times++))
	do
		#get the final bw data
		paste $final_read_bw_file_name bw-*-read-${test_times} > /tmp/data.tmp
		cp /tmp/data.tmp $final_read_bw_file_name
		paste $final_write_bw_file_name bw-*-write-${test_times} > /tmp/data.tmp
		cp /tmp/data.tmp $final_write_bw_file_name
		paste $final_randread_bw_file_name bw-*-randread-${test_times} > /tmp/data.tmp
		cp /tmp/data.tmp $final_randread_bw_file_name
		paste $final_randwrite_bw_file_name bw-*-randwrite-${test_times} > /tmp/data.tmp
		cp /tmp/data.tmp $final_randwrite_bw_file_name

		#get the final iops data
		paste $final_read_iops_file_name iops-*-read-${test_times} > /tmp/data.tmp
		cp /tmp/data.tmp $final_read_iops_file_name
		paste $final_write_iops_file_name iops-*-write-${test_times} > /tmp/data.tmp
		cp /tmp/data.tmp $final_write_iops_file_name
		paste $final_randread_iops_file_name iops-*-randread-${test_times} > /tmp/data.tmp
		cp /tmp/data.tmp $final_randread_iops_file_name
		paste $final_randwrite_iops_file_name iops-*-randwrite-${test_times} > /tmp/data.tmp
		cp /tmp/data.tmp $final_randwrite_iops_file_name		

		#get the final latency data
		paste $final_read_latency_file_name latency-*-read-${test_times} > /tmp/data.tmp
		cp /tmp/data.tmp $final_read_latency_file_name
		paste $final_write_latency_file_name latency-*-write-${test_times} > /tmp/data.tmp
		cp /tmp/data.tmp $final_write_latency_file_name
		paste $final_randread_latency_file_name latency-*-randread-${test_times} > /tmp/data.tmp
		cp /tmp/data.tmp $final_randread_latency_file_name
		paste $final_randwrite_latency_file_name latency-*-randwrite-${test_times} > /tmp/data.tmp
		cp /tmp/data.tmp $final_randwrite_latency_file_name		
	done
	cd $PWD
}   

progress_dots()
{
while true
do 
	echo -e ".\c"
	sleep 2
done	
}

#start as a background function
progress_dots &

#get the last bg process
progress_dots_pid=$!

fio_auto_test_multi_process

kill -9 $progress_dots_pid

exit 0
