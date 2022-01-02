#/bin/bash

# Запускаем одновременно 2 команды с разным приоритетом
time nice -n -20 su -c "dd if=/dev/zero of=/tmp/test.img bs=2000 count=1M" &  time nice -n 19 su -c "dd if=/dev/zero of=/tmp/test2.img bs=2000 count=1M" &

# Результат

# 1048576+0 records in
# 1048576+0 records out
# 2097152000 bytes (2.1 GB) copied, 4.91873 s, 426 MB/s

# real    0m6.025s
# user    0m0.278s
# sys     0m3.428s
# 1048576+0 records in
# 1048576+0 records out
# 2097152000 bytes (2.1 GB) copied, 9.44011 s, 222 MB/s

# real    0m9.514s
# user    0m0.266s
# sys     0m3.162s
