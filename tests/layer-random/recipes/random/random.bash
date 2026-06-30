echo "Installing random"

python3 - <<EOF &
import random
import time
min = 0.0
max = 5.0
k = 2.0
rand = min + (max - min) * (1.0 - random.random()**(1.0 / k))
print(f"Sleeping for {rand:.2f}s")
time.sleep(rand)
EOF
sleep_pid=$!

echo "Random installation sent to background (PID: $sleep_pid)"

COUNTER=0
while [[ -e /proc/"$sleep_pid" ]]; do
    echo "Waiting for installation task to finish #$((COUNTER++))"
    sleep 0.01
done

wait

exit $(( RANDOM % 2 ))
