#!/bin/bash
#  Description: read the data file and generate gnuplot scripts and call gnuplot to generate pictures
#
#  Author: wujing(wulin_cqu@cqu.edu.cn)
#
#  Revision History: 
#



#data_file_path="/home/wujing/work/hdd/linux-work/fgcs-exp/result/pmfs-fileserver"
data_file_path="/dev/shm/pmfs-fileserver"
#data_file_name_pattern="simfs-make-"
#data_file_name_pattern="pmfs-oltp-"
data_file_name_pattern="pmfs-"

cd $data_file_path

for f in `ls $data_file_name_pattern*`
do
	echo $f
	echo "set term jpeg font \"Arial\"" >> /dev/shm/gnuplot.cmd
	#echo "set size 0.5, 0.5" >> /dev/shm/gnuplot.cmd
	echo "set palette gray" >> /dev/shm/gnuplot.cmd
	echo "set output \"$f.jpg\"" >> /dev/shm/gnuplot.cmd
	echo "unset key" >> /dev/shm/gnuplot.cmd
	echo "set xlabel \"Page Frame\"" >> /dev/shm/gnuplot.cmd
	echo "set ylabel \"Number of Page Writes\"" >> /dev/shm/gnuplot.cmd
	echo "set yrange [0:5000]" >> /dev/shm/gnuplot.cmd
	echo "set xrange [0:500000]" >> /dev/shm/gnuplot.cmd
	echo "plot \"$f\" lt -1 with dots" >> /dev/shm/gnuplot.cmd
	gnuplot /dev/shm/gnuplot.cmd
	rm /dev/shm/gnuplot.cmd
done


exit 0
