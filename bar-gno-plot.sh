#!/bin/bash
#  Description: read the data file and generate gnuplot scripts and call gnuplot to generate pictures
#
#  Author: wujing(wulin_cqu@cqu.edu.cn)
#
#  Revision History: 
#



#data_file_path="/home/wujing/work/hdd/linux-work/fgcs-exp/result/pmfs-fileserver"
data_file_path="/dev/shm/"
#data_file_name_pattern="simfs-make-"
#data_file_name_pattern="pmfs-oltp-"
data_file_name_pattern="simfs-fileserver-"

cd $data_file_path

for f in `ls $data_file_name_pattern*`
do
	echo $f
	echo "set term jpeg font \"Arial\"" >> /dev/shm/gnuplot.cmd
	echo "set style data histogram" >> /dev/shm/gnuplot.cmd
	echo "set style histogram clustered gap 1" >> /dev/shm/gnuplot.cmd
	echo "set style fill solid noborder" >> /dev/shm/gnuplot.cmd
	echo "set output \"$f.jpg\"" >> /dev/shm/gnuplot.cmd
	echo "set key box left" >> /dev/shm/gnuplot.cmd
	echo "set xlabel \"BlockSize\"" >> /dev/shm/gnuplot.cmd
	echo "set ylabel \"Throughput(MB/s)\"" >> /dev/shm/gnuplot.cmd
	echo "plot \"$f\" using 2:xticlabels(1) title columnheader(2) lc rgb \"gray60\", \"$f\" using 3:xticlabels(1) title columnheader(3) lc rgb \"gray40\", \"$f\" using 4:xticlabels(1) title columnheader(4) lc rgb \"gray20\", \"$f\" using 5:xticlabels(1) title columnheader(5) lc rgb \"gray0\"" >> /dev/shm/gnuplot.cmd
	gnuplot /dev/shm/gnuplot.cmd
	rm /dev/shm/gnuplot.cmd
done


exit 0
